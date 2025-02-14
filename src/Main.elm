module Main exposing (main)

import Browser
import Html exposing (Html, a, button, div, h1, img, input, label, li, ol, p, span, text)
import Html.Attributes exposing (alt, checked, class, for, href, id, name, placeholder, src, target, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Random
import Random.List


seedFromInput : String -> Random.Seed
seedFromInput str =
    str
        |> String.toList
        |> List.map Char.toCode
        |> List.sum
        |> Random.initialSeed


type SeedInput
    = Empty
    | SeedValue String


type Set
    = OriginalSet

type alias Model =
    { seedInput : SeedInput
    , setSelection : Set
    , showPlayer1Cards : Bool
    , showPlayer2Cards : Bool
    , showPlayer3Cards : Bool
    , showPlayer4Cards : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { seedInput = Empty
      , setSelection = OriginalSet
      , showPlayer1Cards = False
      , showPlayer2Cards = False
      , showPlayer3Cards = False
      , showPlayer4Cards = False
      }
    , Cmd.none
    )


type Msg
    = HandleSeedInput String
    | HandleSetSelection Set Bool
    | ToggleShowPlayer1Cards
    | ToggleShowPlayer2Cards
    | ToggleShowPlayer3Cards
    | ToggleShowPlayer4Cards
    | FillRandomSeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        HandleSeedInput "" ->
            ( { model
                | seedInput = Empty
                , showPlayer1Cards = False
                , showPlayer2Cards = False
                , showPlayer3Cards = False
                , showPlayer4Cards = False
              }
            , Cmd.none
            )

        HandleSetSelection set _ ->
            ( { model
                | setSelection = set
                , showPlayer1Cards = False
                , showPlayer2Cards = False
                , showPlayer3Cards = False
                , showPlayer4Cards = False
              }
            , Cmd.none
            )

        HandleSeedInput str ->
            ( { model | seedInput = SeedValue str }, Cmd.none )

        ToggleShowPlayer1Cards ->
            ( { model | showPlayer1Cards = not model.showPlayer1Cards }, Cmd.none )

        ToggleShowPlayer2Cards ->
            ( { model | showPlayer2Cards = not model.showPlayer2Cards }, Cmd.none )

        ToggleShowPlayer3Cards ->
            ( { model | showPlayer3Cards = not model.showPlayer3Cards }, Cmd.none )

        ToggleShowPlayer4Cards ->
            ( { model | showPlayer4Cards = not model.showPlayer4Cards }, Cmd.none )

        FillRandomSeed ->
            let
                randomChar : Random.Generator Char
                randomChar =
                    Random.map (\num -> Char.fromCode num) (Random.int 97 122)

                randomString : Random.Generator String
                randomString =
                    Random.map String.fromList (Random.list 10 randomChar)
            in
            ( model, Random.generate HandleSeedInput randomString )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


renderCard : String -> Html Msg
renderCard imageUrl =
    div [ class "flip-card" ]
        [ div [ class "flip-card-inner" ]
            [ div [ class "flip-card-back" ] [ img [ class "card", src imageUrl ] [] ]
            , div [ class "flip-card-front" ] [ img [ class "card", src "battle-goal-back.jpg" ] [] ]
            ]
        ]


renderPlayer : Msg -> Bool -> Int -> Int -> Int -> Html Msg
renderPlayer handleClick showCards first second index =
    let
        imageUrl : Int -> String
        imageUrl number =
            String.fromInt number ++ ".jpg"
    in
    div
        [ class "player"
        , class
            (if showCards then
                "flip"

             else
                ""
            )
        ]
        [ div [ class "player-title" ] [ text ("Spieler " ++ String.fromInt index) ]
        , button [ class "toggle", onClick handleClick ]
            [ text
                (if showCards then
                    "Hide"

                 else
                    "Show"
                )
            ]
        , div [ class "cards-container" ]
            [ renderCard (imageUrl first)
            , renderCard (imageUrl second)
            ]
        ]


renderPlayers : Model -> String -> List (Html Msg)
renderPlayers model seedValue =
    let
        ( min, max ) =
            case model.setSelection of
                OriginalSet ->
                    ( 1, 32 )

        numbers : List Int
        numbers =
            seedValue
                |> seedFromInput
                |> Random.step (Random.List.shuffle (List.range min max))
                |> Tuple.first
                |> List.take 8
    in
    case numbers of
        [ first, second, third, fourth, fifth, sixth, seventh, eigth ] ->
            [ renderPlayer ToggleShowPlayer1Cards model.showPlayer1Cards first second 1
            , renderPlayer ToggleShowPlayer2Cards model.showPlayer2Cards third fourth 2
            , renderPlayer ToggleShowPlayer3Cards model.showPlayer3Cards fifth sixth 3
            , renderPlayer ToggleShowPlayer4Cards model.showPlayer4Cards seventh eigth 4
            ]

        _ ->
            [ div [] [ text "Etwas ist schief gegangen." ] ]


renderPlayersContainer : Model -> Html Msg
renderPlayersContainer model =
    case model.seedInput of
        Empty ->
            div [ class "players-container" ] []

        SeedValue seedValue ->
            div [ class "players-container" ] (renderPlayers model seedValue)


renderSeedInput : Model -> Html Msg
renderSeedInput model =
    let
        seedInputValue : String
        seedInputValue =
            case model.seedInput of
                Empty ->
                    ""

                SeedValue seedValue ->
                    seedValue
    in
    div [ class "seed-input" ]
        [ div []
            [ label [ for "seed-input" ] [ text "Seed Eingabe" ]
            , input [ id "seed-input", onInput HandleSeedInput, placeholder "Seed eingeben", value seedInputValue ] [ text "" ]
            ]
        , div [] [ button [ onClick FillRandomSeed ] [ text "Zufälligen Seed erzeugen" ] ]
        ]


renderSetSelection : Model -> Html Msg
renderSetSelection model =
    let
        radioButton : String -> String -> Set -> Html Msg
        radioButton idString labelString set =
            div
                [ class "radio-button-container"
                , class
                    (if model.setSelection == set then
                        "selected"

                     else
                        ""
                    )
                ]
                [ input
                    [ type_ "radio"
                    , id idString
                    , name "set-selection"
                    , onCheck (HandleSetSelection set)
                    , checked (model.setSelection == set)
                    ]
                    []
                , label [ for idString ] [ text labelString ]
                ]
    in
    div [ class "set-selection" ]
        [ p [] [ text "Benutzte Karten" ]
        , div [ class "radio-button-group" ]
            [ radioButton "option-original" "Original" OriginalSet ]
        ]


renderTopSection : Html Msg
renderTopSection =
    div []
        [ h1 [] [ text "Pranken des Löwen Kampfziel Generator" ]
        , p [ class "summary" ]
            [ span [] [ text "Eine Webapp die einer Gruppe hilft die Kampfziele für Gloomhaven Pranken des Löwen zu koordinieren." ]]
        , p [] [ text "Wie es geht:" ]
        , ol []
            [ li [] [ span [ class "emphasize" ] [ text "Entscheide" ], span [] [ text " dich mit deiner Gruppe für einen guten Seedwert (z.B. 'DieBartDie42') und welcher Spieler welche Nummer ist." ] ]
            , li [] [ span [ class "emphasize" ] [ text "Eingabe" ], span [] [ text " des Seedwert in die folgende Box und klicke auf 'Anzeigen'!" ] ]
            , li [] [ span [] [ text "(optional) " ], span [ class "emphasize" ] [ text "Teile" ], span [] [ text " den Seedwert mit deinen Mitspielern. Sie können Ihn eingeben um das gleiche Ergebnis zu erhalten." ] ]
            ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "top-section" ] [ renderTopSection ]
        , div [ class "main-section" ]
            [ renderSetSelection model
            , renderSeedInput model
            , renderPlayersContainer model
            ]
        , div [ class "source-link" ]
            [ a [ href "https://github.com/ToM-Korn/kampfziele", target "_blank" ]
                [ img [ alt "Github Mark", class "github-mark", src "GitHub-Mark-32px.png" ] []
                ]
            ]
        ]


main : Program () Model Msg
main =
    Browser.element { init = init, update = update, view = view, subscriptions = subscriptions }
