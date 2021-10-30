port module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Config exposing (makeApiUrl)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, field, int, list, map2, map5, string)
import Json.Encode
import Pages.Feed exposing (feedView)
import Task
import Time
import Types exposing (Author, Model, Msg(..), Post)
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



-- PORTS


port showAlert : String -> Cmd msg


port requestLogout : () -> Cmd msg



-- INIT


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { posts = Nothing
      , now = Time.millisToPosix 0
      , composeInputValue = ""
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

        RequestLogout ->
            ( model, requestLogout () )

        GetPosts ->
            ( model, getPosts )

        GotPosts (Result.Ok posts) ->
            ( { model | posts = Just posts }, Cmd.none )

        GotPosts (Result.Err httpErr) ->
            ( model
            , showAlert <| httpErrorToString httpErr
            )

        LikePost post ->
            ( model, likePost post )

        LikedPost (Result.Ok post) ->
            ( { model | posts = Just <| replaceMatchingPost post (Maybe.withDefault [] model.posts) }
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
                | posts = Maybe.map (\posts -> post :: posts) model.posts
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
                    , ( "author"
                      , Json.Encode.object
                            [ ( "id", Json.Encode.string "logged-in-user-id" )
                            , ( "name", Json.Encode.string "Logged in user" )
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
    , body = button [ onClick RequestLogout ] [ text "Logout" ] :: feedView model |> List.map toUnstyled
    }



-- UTILS


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl url ->
            "URL {0} is invalid" |> templ [ url ]

        Http.Timeout ->
            "Request has timed out"

        Http.NetworkError ->
            "Unable to reach the server, check your network connection"

        Http.BadStatus status ->
            "Server responded with status {0}" |> templ [ String.fromInt status ]

        Http.BadBody msg ->
            msg


templ : List String -> String -> String
templ rs original =
    let
        templElement_ : ( Int, String ) -> String -> String
        templElement_ ( index, r ) orig_ =
            String.replace ("{" ++ String.fromInt index ++ "}") r orig_
    in
    List.indexedMap Tuple.pair rs
        |> List.foldl templElement_ original
