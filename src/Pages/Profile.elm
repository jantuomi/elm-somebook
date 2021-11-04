module Pages.Profile exposing (..)

import Css exposing (marginBottom, px)
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css)
import Types exposing (Model, Msg, UrlSegmentUserId)


styles =
    { container =
        css
            [ marginBottom (px 10)
            ]
    }


body : Model -> UrlSegmentUserId -> Html Msg
body _ id =
    div [ styles.container ]
        [ text id ]


profileView : UrlSegmentUserId -> Model -> List (Html Msg)
profileView userId model =
    [ body model userId ]
