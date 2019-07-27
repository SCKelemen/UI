module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, ul, li)
import Html.Attributes exposing (src, style)


---- MODEL ----


type alias Model =
    { entries : List Document
    , viewEntries : List Document
    , query : Maybe String
    , filter : Maybe String
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
emptyModel = { entries = [item1, item2, item1, item2, item1, item2, item1, item2]
             , viewEntries = [item1, item2, item1, item2, item1, item2, item1, item2 ] 
             , query = Nothing
             , filter = Nothing
             }

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
    div [ style "margin-top" "0px"
        , style "background-color" "#fefefe"
        ]
        [ renderHeader
        , renderLabel        
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
        (List.map renderDoc lst )

documentStyles : List (String, String) 
documentStyles = 
    [ ("display", "block"), ("width", "320px"), ("height", "260px"), ("background-color", "red")]        


renderDoc : Document -> Html msg 
renderDoc doc = 
    div [ style "display" "block"
        , style "width" "320px"
        , style "height" "260px"
        , style "background-color" "red"
        ] [ text doc.title 
          , text doc.uid
          ]

renderHeader : Html msg  
renderHeader = 
    div [ style "width" "100vw"
        , style "display" "block"
        , style "background-color" "black"
        , style "height" "48px"
        --, style "position" "absolute" 
        , style "margin-top" "0px"
        , style "color" "#fff"
    ] [ headerTitle ]

headerTitle : Html msg 
headerTitle = 
    h1  [ style "margin-top" "0px"
        , style "float" "left"
        , style "margin" "6px 2em" 
        ] [ text "Librarian" ]

renderLabel : Html msg 
renderLabel =
    h1  [  style "text-align" "left"
        ,  style  "margin-left" "2em"
    ] [ text "Documents"]

---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
