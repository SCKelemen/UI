import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

-- MAIN

main =
  Browser.sandbox { init = init, update = update, view = view }


-- MODEL

type alias Model =
  { name : String
  , title : String
  , url : String
  , solution : String
  , feature : String
  }

init : Model
init =
  Model "" "" "" "" ""


-- UPDATE

type Msg
  = Name String
  | Title String
  | Resource String
  | Solution String
  | Feature String


update : Msg -> Model -> Model
update msg model =
  case msg of
    Name name ->
      { model | name = name }

    Title title ->
      { model | title = title }

    Resource url ->
      { model | url = url }

    Solution solution -> 
      { model | solution = solution }

    Feature feature -> 
      { model | feature = feature }


-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Name" model.name Name
    , viewInput "text" "Title" model.title Title
    , viewInput "text" "Url" model.url Resource
    , viewInput "text" "Solution" model.solution Solution
    , viewInput "text" "Feature" model.feature Feature
    , viewValidation model
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.title /= "" && model.name /= "" && model.url /= "" then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Title, Name, and Url are required." ]
