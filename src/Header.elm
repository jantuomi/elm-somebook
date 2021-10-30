module Header exposing (..)

import Css exposing (..)
import Html.Styled exposing (Html, button, div, text)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Types exposing (Model, Msg(..))
import Utils exposing (templ)


styles =
    { container =
        css
            [ displayFlex
            , flexFlow2 row wrap
            , justifyContent flexEnd
            , width (pct 100)
            , marginBottom (px 10)
            ]
    , logoutButton =
        css
            [ marginLeft (px 10)
            , cursor pointer
            ]
    }


headerView : Model -> List (Html Msg)
headerView model =
    [ div [ styles.container ]
        [ div [] [ "Logged in as {0}" |> templ [ model.userData.name ] |> text ]
        , button [ styles.logoutButton, onClick RequestLogout ] [ text "Logout" ]
        ]
    ]
