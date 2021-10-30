module Utils exposing (..)

import Http



-- UTILS


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl url ->
            "URL {0} is invalid" |> templ [ url ]

        Http.Timeout ->
            "Request has timed out"

        Http.NetworkError ->
            "Unable to reach the server, check your network connection"

        Http.BadStatus status ->
            "Server responded with status {0}" |> templ [ String.fromInt status ]

        Http.BadBody msg ->
            msg


templ : List String -> String -> String
templ rs original =
    let
        templElement_ : ( Int, String ) -> String -> String
        templElement_ ( index, r ) orig_ =
            String.replace (String.replace "n" (String.fromInt index) "{n}") r orig_
    in
    List.indexedMap Tuple.pair rs
        |> List.foldl templElement_ original


listFlat : List (List a) -> List a
listFlat ll =
    List.foldl (\acc l -> l ++ acc) [] ll
