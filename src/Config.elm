module Config exposing (ApiResource(..), makeApiUrl)

import Utils exposing (templ)


baseUrl : String
baseUrl =
    "http://localhost:3000"


type ApiResource
    = ApiPosts
    | ApiLikePost String
    | ApiCompose


makeApiUrl : ApiResource -> String
makeApiUrl res =
    String.replace "{baseUrl}" baseUrl <|
        case res of
            ApiPosts ->
                "{baseUrl}/posts?_sort=createdAt&_order=desc"

            ApiLikePost postId ->
                "{baseUrl}/posts/{0}"
                    |> templ [ postId ]

            ApiCompose ->
                "{baseUrl}/posts"
