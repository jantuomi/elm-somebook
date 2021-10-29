module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Config exposing (makeApiUrl)
import Html.Styled exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, list, map2, map5, string)
import Json.Encode
import Pages.Feed exposing (feedView)
import Task
import Time
import Types exposing (Author, DisplayableError(..), Model, Msg(..), Post)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }



-- INIT


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { posts = []
      , displayError = DNoError
      , now = Time.millisToPosix 0
      }
    , Cmd.batch [ getPosts, Task.perform SetNowPosix Time.now ]
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetNowPosix now ->
            ( { model | now = now }, Cmd.none )

        GetPosts ->
            ( model, getPosts )

        GotPosts (Result.Ok posts) ->
            ( { model | posts = posts }, Cmd.none )

        GotPosts (Result.Err httpErr) ->
            ( { model | displayError = DHttpError httpErr }
            , Cmd.none
            )

        LikePost post ->
            ( model, likePost post )

        LikedPost (Result.Ok post) ->
            ( { model | posts = replaceMatchingPost post model.posts }
            , Cmd.none
            )

        LikedPost (Result.Err httpErr) ->
            ( { model | displayError = DHttpError httpErr }
            , Cmd.none
            )


replaceMatchingPost : Post -> List Post -> List Post
replaceMatchingPost post posts =
    List.map
        (\p ->
            if p.id == post.id then
                post

            else
                p
        )
        posts


getPosts : Cmd Msg
getPosts =
    Http.get
        { url = makeApiUrl Config.ApiPosts
        , expect = Http.expectJson GotPosts postsDecoder
        }


likePost : Post -> Cmd Msg
likePost post =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = makeApiUrl (Config.ApiLikePost post.id)
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "likes", Json.Encode.int (post.likes + 1) ) ]
                )
        , expect = Http.expectJson LikedPost postDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 5000 SetNowPosix



-- JSON


decodeTime : Decoder Time.Posix
decodeTime =
    int
        |> Json.Decode.andThen
            (\ms ->
                Json.Decode.succeed <| Time.millisToPosix (ms * 1000)
            )


postsDecoder : Decoder (List Post)
postsDecoder =
    list postDecoder


postDecoder : Decoder Post
postDecoder =
    map5 Post
        (field "id" string)
        (field "content" string)
        (field "author"
            (map2 Author
                (field "id" string)
                (field "name" string)
            )
        )
        (field "createdAt" decodeTime)
        (field "likes" int)



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Shoob book"
    , body = feedView model |> List.map toUnstyled
    }
