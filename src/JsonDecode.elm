module JsonDecode exposing (..)

import Json.Decode exposing (..)
import Time
import Types exposing (Author, Post)


decodeTime : Decoder Time.Posix
decodeTime =
    int
        |> andThen
            (\ms ->
                succeed <| Time.millisToPosix (ms * 1000)
            )


postsDecoder : Decoder (List Post)
postsDecoder =
    list postDecoder


postDecoder : Decoder Post
postDecoder =
    map7 Post
        (field "id" string)
        (field "content" string)
        (field "author"
            (map2 Author
                (field "id" string)
                (field "name" string)
            )
        )
        (field "createdAt" decodeTime)
        (field "likes" int)
        (field "userPictureUrl" string)
        (maybe <| field "imageUrl" string)
