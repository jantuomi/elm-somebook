port module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Config exposing (makeApiUrl)
import Header exposing (headerView)
import Html.Styled exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, list, map2, map7, maybe, string)
import Json.Encode
import Json.Encode.Extra
import Pages.Feed exposing (feedView)
import Pages.Profile exposing (profileView)
import RemoteData
import Routes exposing (routeParser)
import Task
import Time
import Types exposing (Author, Flags, Model, Msg(..), Post, Route(..))
import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, oneOf, s)
import Utils exposing (httpErrorToString, listFlat)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- PORTS


port showAlert : String -> Cmd msg


port requestLogout : () -> Cmd msg



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        initModel : Model
        initModel =
            { now = Time.millisToPosix 0
            , key = key
            , url = url
            , userData = flags.userData
            , apiURL = flags.apiURL
            , posts = RemoteData.Loading
            , composeTextInputValue = ""
            , composeImageInputValue = ""
            }
    in
    ( initModel
    , Cmd.batch
        [ getPosts initModel
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

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        -- BUSINESS LOGIC
        GetPosts ->
            ( model, getPosts model )

        GotPosts (Result.Ok posts) ->
            ( { model | posts = RemoteData.Success posts }, Cmd.none )

        GotPosts (Result.Err httpErr) ->
            ( { model | posts = RemoteData.Failure httpErr }
            , showAlert <| httpErrorToString httpErr
            )

        LikePost post ->
            ( model, likePost model post )

        LikedPost (Result.Ok post) ->
            ( { model | posts = RemoteData.map (replaceMatchingPost post) model.posts }
            , Cmd.none
            )

        LikedPost (Result.Err httpErr) ->
            ( model
            , showAlert <| httpErrorToString httpErr
            )

        ComposeTextInputChanged value ->
            ( { model | composeTextInputValue = value }, Cmd.none )

        ComposeImageInputChanged value ->
            ( { model | composeImageInputValue = value }, Cmd.none )

        ComposePost ->
            ( model
            , if String.length model.composeTextInputValue > 0 then
                composePost model

              else
                Cmd.none
            )

        ComposedPost (Result.Ok post) ->
            ( { model
                | posts = RemoteData.map (\posts -> post :: posts) model.posts
                , composeTextInputValue = ""
                , composeImageInputValue = ""
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


getPosts : Model -> Cmd Msg
getPosts model =
    Http.get
        { url = makeApiUrl model Config.ApiPosts
        , expect = Http.expectJson GotPosts postsDecoder
        }


likePost : Model -> Post -> Cmd Msg
likePost model post =
    Http.request
        { method = "PATCH"
        , headers = []
        , url = makeApiUrl model (Config.ApiLikePost post.id)
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
    let
        imageUrl : Maybe String
        imageUrl =
            if model.composeImageInputValue /= "" then
                Just model.composeImageInputValue

            else
                Nothing
    in
    Http.post
        { url = makeApiUrl model Config.ApiCompose
        , expect = Http.expectJson ComposedPost postDecoder
        , body =
            Http.jsonBody
                (Json.Encode.object
                    [ ( "content", Json.Encode.string model.composeTextInputValue )
                    , ( "createdAt", Json.Encode.int <| Time.posixToMillis model.now // 1000 )
                    , ( "likes", Json.Encode.int 0 )
                    , ( "userPictureUrl", Json.Encode.string model.userData.pictureUrl )
                    , ( "imageUrl", Json.Encode.Extra.maybe Json.Encode.string imageUrl )
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
    Sub.batch
        [ Time.every 5000 SetNowPosix
        , Time.every 5000 (\_ -> GetPosts)
        ]



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
    map7 Post
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
        (maybe <| field "imageUrl" string)



-- VIEW


urlToView : Url -> (Model -> List (Html Msg))
urlToView url =
    let
        route =
            Url.Parser.parse routeParser url
    in
    case route of
        Just Index ->
            feedView

        Just (Profile id) ->
            profileView id

        Nothing ->
            feedView


view : Model -> Document Msg
view model =
    { title = "SOMEBOOK"
    , body =
        [ headerView model, urlToView model.url model ]
            |> listFlat
            |> List.map toUnstyled
    }
