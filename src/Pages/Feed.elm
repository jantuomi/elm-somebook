module Pages.Feed exposing (..)

import Css exposing (..)
import DateFormat.Relative exposing (relativeTime)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, placeholder, type_, value)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)
import Time exposing (now)
import Types exposing (Model, Msg(..), Post)


styles =
    { page =
        css
            [ maxWidth (px 600)
            , margin2 (px 10) auto
            ]
    , post =
        css
            [ padding2 (px 15) (px 20)
            , backgroundColor (hex "#eee")
            , marginBottom (px 10)
            ]
    , postTitle =
        css
            [ margin (px 0) ]
    , postLikeButton =
        css
            [ marginRight (px 5)
            , cursor pointer
            ]
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


postDiv : Time.Posix -> Post -> Html Msg
postDiv now post =
    div [ styles.post ]
        [ h3 [ styles.postTitle ] [ text post.author.name ]
        , i []
            [ text <| relativeTime now post.createdAt
            ]
        , p [] [ text post.content ]
        , span []
            [ button [ styles.postLikeButton, onClick (LikePost post) ] [ text "❤️ Like" ]
            , text <| String.fromInt post.likes
            ]
        ]


postsDiv : Model -> Html Msg
postsDiv model =
    case model.posts of
        Just posts ->
            div [] <| List.map (postDiv model.now) posts

        Nothing ->
            div [] [ text "Loading posts..." ]


composeDiv : Model -> Html Msg
composeDiv model =
    form [ styles.composeForm, onSubmit ComposePost ]
        [ input
            [ styles.composeInput
            , placeholder "Type a new post..."
            , onInput ComposeInputChanged
            , value model.composeInputValue
            ]
            []
        , button [ type_ "submit" ] [ text "➡️" ]
        ]


headerSection : Model -> Html msg
headerSection _ =
    header []
        [ h1 [] [ text "Shoob book" ]
        ]


mainSection : Model -> Html Msg
mainSection model =
    main_ [] <|
        [ postsDiv model
        , composeDiv model
        ]


body : Model -> Html Msg
body model =
    div [ styles.page ]
        [ headerSection model
        , mainSection model
        ]


feedView : Model -> List (Html Msg)
feedView model =
    [ body model ]
