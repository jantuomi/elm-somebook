module Types exposing (..)

import Browser.Navigation exposing (Key)
import Http
import RemoteData exposing (RemoteData)
import Time


type alias Model =
    { now : Time.Posix
    , key : Key
    , userData : UserData
    , apiURL : String
    , posts : RemoteData (List Post)
    , composeTextInputValue : String
    , composeImageInputValue : String
    }


type alias Flags =
    { userData : UserData
    , apiURL : String
    }


type alias UserData =
    { name : String
    , email : String
    , pictureUrl : String
    }


type Msg
    = NoOp
    | RequestLogout
      -- TIME
    | SetNowPosix Time.Posix
      -- POSTS
    | GetPosts
    | GotPosts (Result Http.Error (List Post))
    | LikePost Post
    | LikedPost (Result Http.Error Post)
      -- COMPOSE POST
    | ComposeTextInputChanged String
    | ComposeImageInputChanged String
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
    , userPictureUrl : String
    , imageUrl : Maybe String
    }
