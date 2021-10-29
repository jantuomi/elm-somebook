module Main exposing (..)

import Browser exposing (Document)
import Browser.Navigation exposing (Key)
import Html.Styled exposing (..)
import Types exposing (DisplayableError(..), Model, Msg(..))
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = \_ -> NoOp
        , onUrlChange = \_ -> NoOp
        }



-- INIT


init : () -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { posts =
            [ { id = "123"
              , content = "foobar"
              , author =
                    { id = "456"
                    , name = "George Technoman"
                    }
              }
            ]
      , displayError = NoError
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        FetchPostsSuccess posts ->
            ( { model | posts = posts }, Cmd.none )

        FetchPostsFailure error ->
            ( { model | displayError = error }, Cmd.none )



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Shoob book"
    , body = [ body model ] |> List.map toUnstyled
    }


body : Model -> Html Msg
body model =
    main_ [] (List.map (\post -> div [] [ text post.id ]) model.posts)
