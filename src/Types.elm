module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Http
import RemoteData exposing (RemoteData)
import Time
import Url exposing (Url)


type alias Model =
    { now : Time.Posix
    , key : Key
    , url : Url
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
      -- NAVIGATION
    | UrlChanged Url
    | LinkClicked UrlRequest
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


type Route
    = Index
    | Profile UrlSegmentUserId


type alias Author =
    { id : String
    , name : String
    }


type alias UrlSegmentUserId =
    String


type alias Post =
    { id : String
    , content : String
    , author : Author
    , createdAt : Time.Posix
    , likes : Int
    , userPictureUrl : String
    , imageUrl : Maybe String
    }
