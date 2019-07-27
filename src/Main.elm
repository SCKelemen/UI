module Main exposing (..)


import Browser
import Browser.Navigation as Nav
import Dict
import Elm.Version as V
import Html
import Page.Docs as Docs
import Page.Diff as Diff
import Page.Help as Help
import Page.Problem as Problem
import Page.Search as Search
import Session
import Skeleton
import Url
import Url.Parser as Parser exposing (Parser, (</>), custom, fragment, map, oneOf, s, top)



-- MAIN


main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlRequest = LinkClicked
    , onUrlChange = UrlChanged
    }



-- MODEL


type alias Model =
  { key : Nav.Key
  , page : Page
  }


type Page
  = NotFound Session.Data
  | Search Search.Model
  | Docs Docs.Model
  | Diff Diff.Model
  | Help Help.Model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  case model.page of
    NotFound _ ->
      Skeleton.view never
        { title = "Not Found"
        , header = []
        , warning = Skeleton.NoProblems
        , attrs = Problem.styles
        , kids = Problem.notFound
        }

    Search search ->
      Skeleton.view SearchMsg (Search.view search)

    Docs docs ->
      Skeleton.view DocsMsg (Docs.view docs)

    Diff diff ->
      Skeleton.view never (Diff.view diff)

    Help help ->
      Skeleton.view never (Help.view help)



-- INIT


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
  stepUrl url
    { key = key
    , page = NotFound Session.empty
    }



-- UPDATE


type Msg
  = NoOp
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | SearchMsg Search.Msg
  | DiffMsg Diff.Msg
  | DocsMsg Docs.Msg
  | HelpMsg Help.Msg



update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    NoOp ->
      ( model, Cmd.none )

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model
          , Nav.pushUrl model.key (Url.toString url)
          )

        Browser.External href ->
          ( model
          , Nav.load href
          )

    UrlChanged url ->
      stepUrl url model

    SearchMsg msg ->
      case model.page of
        Search search -> stepSearch model (Search.update msg search)
        _             -> ( model, Cmd.none )

    DiffMsg msg ->
      case model.page of
        Diff diff -> stepDiff model (Diff.update msg diff)
        _         -> ( model, Cmd.none )

    DocsMsg msg ->
      case model.page of
        Docs docs -> stepDocs model (Docs.update msg docs)
        _         -> ( model, Cmd.none )

    HelpMsg msg ->
      case model.page of
        Help docs -> stepHelp model (Help.update msg docs)
        _         -> ( model, Cmd.none )


stepSearch : Model -> ( Search.Model, Cmd Search.Msg ) -> ( Model, Cmd Msg )
stepSearch model (search, cmds) =
  ( { model | page = Search search }
  , Cmd.map SearchMsg cmds
  )


stepDocs : Model -> ( Docs.Model, Cmd Docs.Msg ) -> ( Model, Cmd Msg )
stepDocs model (docs, cmds) =
  ( { model | page = Docs docs }
  , Cmd.map DocsMsg cmds
  )


stepDiff : Model -> ( Diff.Model, Cmd Diff.Msg ) -> ( Model, Cmd Msg )
stepDiff model (diff, cmds) =
  ( { model | page = Diff diff }
  , Cmd.map DiffMsg cmds
  )


stepHelp : Model -> ( Help.Model, Cmd Help.Msg ) -> ( Model, Cmd Msg )
stepHelp model (help, cmds) =
  ( { model | page = Help help }
  , Cmd.map HelpMsg cmds
  )



-- EXIT


exit : Model -> Session.Data
exit model =
  case model.page of
    NotFound session -> session
    Search m -> m.session
    Docs m -> m.session
    Diff m -> m.session
    Help m -> m.session



-- ROUTER


stepUrl : Url.Url -> Model -> (Model, Cmd Msg)
stepUrl url model =
  let
    session =
      exit model

    parser =
      oneOf
        [ route top
            ( stepSearch model (Search.init session)
            )
        , route (s "packages" </> author_ </> project_)
            (\author project ->
                stepDiff model (Diff.init session author project)
            )
        , route (s "packages" </> author_ </> project_ </> version_ </> focus_)
            (\author project version focus ->
                stepDocs model (Docs.init session author project version focus)
            )
        , route (s "help" </> s "design-guidelines")
            (stepHelp model (Help.init session "Design Guidelines" "/assets/help/design-guidelines.md"))
        , route (s "help" </> s "documentation-format")
            (stepHelp model (Help.init session "Documentation Format" "/assets/help/documentation-format.md"))
        ]
  in
  case Parser.parse parser url of
    Just answer ->
      answer

    Nothing ->
      ( { model | page = NotFound session }
      , Cmd.none
      )


route : Parser a b -> a -> Parser (b -> c) c
route parser handler =
  Parser.map handler parser


author_ : Parser (String -> a) a
author_ =
  custom "AUTHOR" Just


project_ : Parser (String -> a) a
project_ =
  custom "PROJECT" Just


version_ : Parser (Maybe V.Version -> a) a
version_ =
  custom "VERSION" <| \string ->
    if string == "latest" then
      Just Nothing
    else
      Maybe.map Just (V.fromString string)


focus_ : Parser (Docs.Focus -> a) a
focus_ =
  oneOf
    [ map Docs.Readme top
    , map Docs.Module (moduleName_ </> fragment identity)
    ]


moduleName_ : Parser (String -> a) a
moduleName_ =
  custom "MODULE" (Just << String.replace "-" ".")