module Components.PostList exposing (..)

import Css exposing (..)
import DateFormat.Relative exposing (relativeTime)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Html.Styled.Events exposing (onClick)
import Html.Styled.Keyed as Keyed
import Html.Styled.Lazy exposing (lazy)
import Time
import Types exposing (Msg(..), Post)
import Utils exposing (templ)


styles =
    { postList =
        css
            [ marginBottom (px 10)
            ]
    , post =
        css
            [ padding2 (px 15) (px 20)
            , backgroundColor (hex "#eee")
            , marginBottom (px 10)
            ]
    , postImage =
        css
            [ marginBottom (px 20)
            ]
    , postProfilePicture =
        css
            [ width (px 40)
            , height (px 40)
            ]
    , postHeader =
        css
            [ display inlineBlock
            , marginLeft (px 10)
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


postDiv : Time.Posix -> Post -> Html Msg
postDiv now post =
    let
        imageElem =
            case post.imageUrl of
                Just url ->
                    img [ styles.postImage, src url ] []

                Nothing ->
                    text ""
    in
    div
        [ styles.post ]
        [ a [ href <| templ [ post.author.id ] "/profile/{0}" ]
            [ span []
                [ img [ styles.postProfilePicture, src post.userPictureUrl ] [] ]
            , span [ styles.postHeader ]
                [ h3 [ styles.postTitle ] [ text post.author.name ]
                , i []
                    [ text <| relativeTime now post.createdAt
                    ]
                ]
            ]
        , p [] [ text post.content ]
        , imageElem
        , span []
            [ button [ styles.postLikeButton, onClick (LikePost post) ] [ text "👏 Clap" ]
            , text <| String.fromInt post.likes
            ]
        ]


keyedPostDiv : Time.Posix -> Post -> ( String, Html Msg )
keyedPostDiv now post =
    ( post.id, lazy (postDiv now) post )


postList : Time.Posix -> List Post -> Html Msg
postList now posts =
    Keyed.node "div" [ styles.postList ] <| List.map (keyedPostDiv now) posts
