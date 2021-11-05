module JsonEncode exposing (..)

import Json.Encode exposing (..)
import Json.Encode.Extra exposing (..)
import Time
import Types exposing (Model, Post)


composePostEncoder : Model -> Value
composePostEncoder model =
    let
        imageUrl : Maybe String
        imageUrl =
            if model.composeImageInputValue /= "" then
                Just model.composeImageInputValue

            else
                Nothing
    in
    object
        [ ( "content", string model.composeTextInputValue )
        , ( "createdAt", Json.Encode.int <| Time.posixToMillis model.now // 1000 )
        , ( "likes", Json.Encode.int 0 )
        , ( "userPictureUrl", Json.Encode.string model.userData.pictureUrl )
        , ( "imageUrl", maybe Json.Encode.string imageUrl )
        , ( "author"
          , Json.Encode.object
                [ ( "id", Json.Encode.string model.userData.email )
                , ( "name", Json.Encode.string model.userData.name )
                ]
          )
        ]


likePostEncoder : Post -> Value
likePostEncoder post =
    Json.Encode.object
        [ ( "likes", Json.Encode.int (post.likes + 1) ) ]
