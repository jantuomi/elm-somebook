module Types exposing (..)

import Http
import Time


type alias Model =
    { posts : Maybe (List Post)
    , composeInputValue : String
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
      -- COMPOSE POST
    | ComposeInputChanged String
    | ComposePost
    | ComposedPost (Result Http.Error Post)


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
