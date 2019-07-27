module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, ul, li)
import Html.Attributes exposing (src, style)


---- MODEL ----


type alias Model =
    { entries : List Document
    ,  viewEntries : List Document           
    }

type alias Document =
    { uid : String 
    , title : String 
    }

item1 : Document 
item1 = 
    { uid = "1"
    , title = "Document 1"
    }

item2 : Document 
item2 =
    { uid = "2"
    , title = "Document 2"
    }    

emptyModel : Model 
emptyModel = { entries = [], viewEntries = [item1, item2, item1, item2, item1, item2, item1, item2 ] }

init : ( Model, Cmd Msg )
init =
    ( emptyModel, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Librarian" ]
        , h1 [] [ text "Sam was here!" ]
        , renderDocs model.viewEntries
        ]


renderDocs : List Document -> Html msg 
renderDocs lst =
    div [ style "display" "grid"
        , style "grid-gap" "16px 0px"
        , style "margin"  "0px 5vw"
        , style "max-width" "90vw"
        , style "background" "#f9f9f9"
        , style "grid-template-columns" "repeat( auto-fill, minmax(320px, 1fr) )"
        ] 
        (List.map (\l -> div [ style "display" "block"
                             , style "width" "320px"
                             , style "height" "260px"
                             , style "background-color" "red"
                             ] [ text l.title ]) lst )

documentStyles : List (String, String) 
documentStyles = 
    [ ("display", "block"), ("width", "320px"), ("height", "260px"), ("background-color", "red")]        

---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
