module Config exposing (ApiResource(..), makeApiUrl)

import Types exposing (Model)
import Utils exposing (templ)


type ApiResource
    = ApiPosts
    | ApiLikePost String
    | ApiCompose


makeApiUrl : Model -> ApiResource -> String
makeApiUrl model res =
    String.replace "{baseUrl}" model.apiURL <|
        case res of
            ApiPosts ->
                "{baseUrl}/posts?_sort=createdAt&_order=desc"

            ApiLikePost postId ->
                "{baseUrl}/posts/{0}"
                    |> templ [ postId ]

            ApiCompose ->
                "{baseUrl}/posts"
