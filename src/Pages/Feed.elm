module Pages.Feed exposing (..)

import Components.PostList exposing (postList)
import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, placeholder, type_, value)
import Html.Styled.Events exposing (onInput, onSubmit)
import RemoteData exposing (RemoteData(..))
import Types exposing (Model, Msg(..))


styles =
    { page =
        css [ margin2 (px 10) auto ]
    , composeForm =
        css
            [ displayFlex
            , flexFlow2 row wrap
            ]
    , composeInput =
        css
            [ flex (int 1)
            ]
    }


postsContainer : Model -> Html Msg
postsContainer model =
    case model.posts of
        Initial ->
            div [] []

        Loading ->
            div [] [ text "Loading posts..." ]

        Failure _ ->
            div [] []

        Success posts ->
            postList model.now posts


composeForm : Model -> Html Msg
composeForm model =
    form [ styles.composeForm, onSubmit ComposePost ]
        [ input
            [ styles.composeInput
            , placeholder "Type a new post..."
            , onInput ComposeTextInputChanged
            , value model.composeTextInputValue
            ]
            []
        , input
            [ styles.composeInput
            , placeholder "Image URL (optional)"
            , onInput ComposeImageInputChanged
            , value model.composeImageInputValue
            ]
            []
        , button [ type_ "submit" ] [ text "➡️" ]
        ]


mainSection : Model -> Html Msg
mainSection model =
    main_ [] <|
        [ composeForm model
        , postsContainer model
        ]


body : Model -> Html Msg
body model =
    div [ styles.page ]
        [ h2 [] [ "All posts" |> text ]
        , mainSection model
        ]


feedView : Model -> List (Html Msg)
feedView model =
    [ body model ]
