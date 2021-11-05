port module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Config exposing (makeApiUrl)
import Header exposing (headerView)
import Html.Styled exposing (..)
import Http
import JsonDecode exposing (postDecoder, postsDecoder)
import JsonEncode exposing (composePostEncoder, likePostEncoder)
import Pages.Feed exposing (feedView)
import Pages.Profile exposing (profileView)
import RemoteData
import Routes exposing (routeParser)
import Task
import Time
import Types exposing (Flags, Model, Msg(..), Post, Route(..))
import Url exposing (Url)
import Url.Parser
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
        , body = Http.jsonBody (likePostEncoder post)
        , expect = Http.expectJson LikedPost postDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


composePost : Model -> Cmd Msg
composePost model =
    Http.post
        { url = makeApiUrl model Config.ApiCompose
        , expect = Http.expectJson ComposedPost postDecoder
        , body = Http.jsonBody (composePostEncoder model)
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Time.every 5000 SetNowPosix
        , Time.every 5000 (\_ -> GetPosts)
        ]



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
