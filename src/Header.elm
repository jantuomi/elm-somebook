module Header exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href)
import Html.Styled.Events exposing (onClick)
import Types exposing (Model, Msg(..))
import Utils exposing (templ)


styles =
    { container =
        css
            [ displayFlex
            , flexFlow2 row wrap
            , justifyContent flexEnd
            , alignItems center
            , width (pct 100)
            , marginBottom (px 10)
            ]
    , logoutButton =
        css
            [ marginLeft (px 10)
            , cursor pointer
            ]
    , flexPad = css [ flex (int 1) ]
    }


headerView : Model -> List (Html Msg)
headerView model =
    [ header [ styles.container ]
        [ a [ href "/" ] [ h1 [] [ text "😎 SOMEBOOK" ] ]
        , div [ styles.flexPad ] []
        , div [] [ "Logged in as {0}" |> templ [ model.userData.name ] |> text ]
        , button [ styles.logoutButton, onClick RequestLogout ] [ text "Logout" ]
        ]
    ]
