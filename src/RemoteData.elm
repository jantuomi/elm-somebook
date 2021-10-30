module RemoteData exposing (..)

import Http


type RemoteData a
    = Initial
    | Loading
    | Failure Http.Error
    | Success a


withDefault : a -> RemoteData a -> a
withDefault default rd =
    case rd of
        Success value ->
            value

        _ ->
            default


map : (a -> b) -> RemoteData a -> RemoteData b
map fn rd =
    case rd of
        Initial ->
            Initial

        Loading ->
            Loading

        Failure err ->
            Failure err

        Success value ->
            Success (fn value)


andThen : (a -> RemoteData b) -> RemoteData a -> RemoteData b
andThen callback rd =
    case rd of
        Initial ->
            Initial

        Loading ->
            Loading

        Failure err ->
            Failure err

        Success value ->
            callback value
