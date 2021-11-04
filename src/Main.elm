port module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Config exposing (makeApiUrl)
import Header exposing (headerView)
import Html.Styled exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, list, map2, map6, string)
import Json.Encode
import Pages.Feed exposing (feedView)
import RemoteData
import Task
import Time
import Types exposing (Author, Model, Msg(..), Post, UserData)
import Url exposing (Url)
import Utils exposing (httpErrorToString, listFlat)


main : Program UserData Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }



-- PORTS


port showAlert : String -> Cmd msg


port requestLogout : () -> Cmd msg



-- INIT


init : UserData -> Url -> Key -> ( Model, Cmd Msg )
init userData _ key =
    ( { now = Time.millisToPosix 0
      , key = key
      , userData = userData
      , posts = RemoteData.Loading
      , composeInputValue = ""
      }
    , Cmd.batch
        [ getPosts
        , Task.perform SetNowPosix Time.now
        ]
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        SetNowPosix now ->
            ( { model | now = now }, Cmd.none )

        RequestLogout ->
            ( model, requestLogout () )

        GetPosts ->
            ( model, getPosts )

        GotPosts (Result.Ok posts) ->
            ( { model | posts = RemoteData.Success posts }, Cmd.none )

        GotPosts (Result.Err httpErr) ->
            ( { model | posts = RemoteData.Failure httpErr }
            , showAlert <| httpErrorToString httpErr
            )

        LikePost post ->
            ( model, likePost post )

        LikedPost (Result.Ok post) ->
            ( { model | posts = RemoteData.map (replaceMatchingPost post) model.posts }
            , Cmd.none
            )

        LikedPost (Result.Err httpErr) ->
            ( model
            , showAlert <| httpErrorToString httpErr
            )

        ComposeInputChanged value ->
            ( { model | composeInputValue = value }, Cmd.none )

        ComposePost ->
            ( model
            , if String.length model.composeInputValue > 0 then
                composePost model

              else
                Cmd.none
            )

        ComposedPost (Result.Ok post) ->
            ( { model
                | posts = RemoteData.map (\posts -> post :: posts) model.posts
                , composeInputValue = ""
              }
            , Cmd.none
            )

        ComposedPost (Result.Err httpErr) ->
            ( model
            , showAlert <| httpErrorToString httpErr
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


composePost : Model -> Cmd Msg
composePost model =
    Http.post
        { url = makeApiUrl Config.ApiCompose
        , expect = Http.expectJson ComposedPost postDecoder
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "content", Json.Encode.string model.composeInputValue )
                    , ( "createdAt", Json.Encode.int <| Time.posixToMillis model.now // 1000 )
                    , ( "likes", Json.Encode.int 0 )
                    , ( "userPictureUrl", Json.Encode.string model.userData.pictureUrl )
                    , ( "author"
                      , Json.Encode.object
                            [ ( "id", Json.Encode.string model.userData.email )
                            , ( "name", Json.Encode.string model.userData.name )
                            ]
                      )
                    ]
                )
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
    map6 Post
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
        (field "userPictureUrl" string)



-- VIEW


view : Model -> Document Msg
view model =
    { title = "SOMEBOOK"
    , body =
        [ headerView model, feedView model ]
            |> listFlat
            |> List.map toUnstyled
    }
