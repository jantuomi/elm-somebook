module Types exposing (..)

import Http
import Time


type alias Model =
    { posts : List Post
    , displayError : DisplayableError
    , now : Time.Posix
    }


type Msg
    = NoOp
      -- TIME
    | SetNowPosix Time.Posix
      -- POSTS
    | GetPosts
    | GotPosts (Result Http.Error (List Post))
    | LikePost Post
    | LikedPost (Result Http.Error Post)


type DisplayableError
    = DHttpError Http.Error
    | DNoError


type alias Author =
    { id : String
    , name : String
    }


type alias Post =
    { id : String
    , content : String
    , author : Author
    , createdAt : Time.Posix
    , likes : Int
    }
