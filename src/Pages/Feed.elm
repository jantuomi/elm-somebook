module Pages.Feed exposing (..)

import Css exposing (..)
import DateFormat.Relative exposing (relativeTime)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Time exposing (now)
import Types exposing (DisplayableError(..), Model, Msg(..), Post)


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
            ]
    , postTitle =
        css
            [ margin (px 0) ]
    , postLikeButton =
        css
            [ marginRight (px 5)
            , cursor pointer
            ]
    }


derrorToHtml : DisplayableError -> Html Msg
derrorToHtml derror =
    case derror of
        DNoError ->
            text ""

        DHttpError httpErr ->
            text <| Debug.toString httpErr


derrorDiv : Model -> Html Msg
derrorDiv model =
    div []
        [ derrorToHtml model.displayError ]


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
    div [] <| List.map (postDiv model.now) model.posts


headerSection : Model -> Html msg
headerSection _ =
    header []
        [ h1 [] [ text "Shoob book" ]
        ]


mainSection : Model -> Html Msg
mainSection model =
    main_ [] <|
        [ derrorDiv model
        , postsDiv model
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
