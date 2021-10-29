module Types exposing (..)


type alias Model =
    { posts : List Post
    , displayError : DisplayableError
    }


type Msg
    = NoOp
    | FetchPostsSuccess (List Post)
    | FetchPostsFailure DisplayableError


type DisplayableError
    = Error String
    | NoError


type alias Author =
    { id : String
    , name : String
    }


type alias Post =
    { id : String
    , content : String
    , author : Author
    }
