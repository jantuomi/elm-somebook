module Config exposing (ApiResource(..), makeApiUrl)


baseUrl : String
baseUrl =
    "http://localhost:3000"


type ApiResource
    = ApiPosts
    | ApiLikePost String


makeApiUrl : ApiResource -> String
makeApiUrl res =
    String.replace "{baseUrl}" baseUrl <|
        case res of
            ApiPosts ->
                "{baseUrl}/posts"

            ApiLikePost postId ->
                "{baseUrl}/posts/{postId}"
                    |> String.replace "{postId}" postId
