module Pages.Profile exposing (..)

import Components.PostList exposing (postList)
import Css exposing (marginBottom, px)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import RemoteData exposing (RemoteData(..))
import Types exposing (Model, Msg, Post, UrlSegmentUserId)
import Utils exposing (templ)


styles =
    { container =
        css
            [ marginBottom (px 10)
            ]
    }


postsContainer : Model -> UrlSegmentUserId -> Html Msg
postsContainer model id =
    let
        onlyProfilePosts : List Post -> List Post
        onlyProfilePosts posts =
            List.filter (\p -> p.author.id == id) posts
    in
    case model.posts of
        Initial ->
            div [] []

        Loading ->
            div [] [ text "Loading posts..." ]

        Failure _ ->
            div [] []

        Success posts ->
            postList model.now (onlyProfilePosts posts)


body : Model -> UrlSegmentUserId -> Html Msg
body model id =
    div [ styles.container ]
        [ h2 [] [ "Posts by {0}" |> templ [ id ] |> text ]
        , postsContainer model id
        ]


profileView : UrlSegmentUserId -> Model -> List (Html Msg)
profileView userId model =
    [ body model userId ]
