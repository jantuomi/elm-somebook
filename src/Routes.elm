module Routes exposing (..)

import Types exposing (Route(..))
import Url.Parser exposing ((</>), Parser, oneOf, s, string, top)


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Url.Parser.map Index top
        , Url.Parser.map Profile (s "profile" </> string)
        ]
