module Main exposing (..)

import Html exposing (Html, text, div, table, thead, tbody, span, tr, th, td, input, form)
import Html.Attributes exposing (src, class)
import Html.Events exposing (onInput, onClick)


---- MODEL ----


type ColumnKey
    = Name
    | Power


type alias Data =
    { name : String, power : Float }


type Order
    = Desc
    | Asc


switchOrder : Order -> Order
switchOrder order =
    case order of
        Desc ->
            Asc

        Asc ->
            Desc


order2string : Order -> String
order2string order =
    case order of
        Desc ->
            "dsc"

        Asc ->
            "asc"


type alias ItemOrder =
    Maybe ( ColumnKey, Order )


type alias Model =
    { searchQuery : String
    , gridData : List Data
    , itemOrder : ItemOrder
    }


infinity : Float
infinity =
    1 / 0


testGridData : List Data
testGridData =
    [ Data "Chuck Norris" infinity
    , Data "Bruce Lee" 9000
    , Data "Jackie Chan" 7000
    , Data "Jet Li" 8000
    ]


init : ( Model, Cmd Msg )
init =
    ( { searchQuery = ""
      , gridData = testGridData
      , itemOrder = Nothing
      }
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = InputSearchQuery String
    | SwitchOrder ColumnKey


update : Msg -> Model -> ( Model, Cmd Msg )
update msg ({ itemOrder } as model) =
    case msg of
        InputSearchQuery q ->
            { model | searchQuery = q } ! []

        SwitchOrder columnKey ->
            case itemOrder of
                Just ( _, order ) ->
                    { model | itemOrder = Just ( columnKey, switchOrder order ) } ! []

                Nothing ->
                    { model | itemOrder = Just ( columnKey, Asc ) } ! []



---- VIEW ----


view : Model -> Html Msg
view { gridData, searchQuery, itemOrder } =
    let
        lwQuery =
            String.toLower searchQuery

        data2tr { name, power } =
            tr []
                [ td [] [ text name ]
                , td [] [ text <| toString power ]
                ]

        gridData2trList =
            List.map data2tr (gridData |> sortList itemOrder |> filterList lwQuery)

        activeClass columnKey =
            Maybe.withDefault "" <|
                Maybe.map
                    (\( key, _ ) ->
                        if columnKey == key then
                            "active"
                        else
                            ""
                    )
                    itemOrder

        arrowClass columnKey =
            Maybe.withDefault "" <|
                Maybe.map
                    (\( key, order ) ->
                        if columnKey == key then
                            "arrow " ++ order2string order
                        else
                            ""
                    )
                    itemOrder
    in
        div []
            [ form []
                [ text "Search"
                , input [ onInput InputSearchQuery ] []
                ]
            , table []
                [ thead []
                    [ tr []
                        [ th [ class <| activeClass Name, onClick <| SwitchOrder Name ]
                            [ text "Name"
                            , span [ class <| arrowClass Name ] []
                            ]
                        , th [ class <| activeClass Power, onClick <| SwitchOrder Power ]
                            [ text "Power"
                            , span [ class <| arrowClass Power ] []
                            ]
                        ]
                    ]
                , tbody []
                    gridData2trList
                ]
            ]


orderProduct : Order -> comparable -> comparable -> Basics.Order
orderProduct order a b =
    case order of
        Asc ->
            compare a b

        Desc ->
            compare b a


sortList : ItemOrder -> List Data -> List Data
sortList itemOrder gridData =
    case itemOrder of
        Just ( columnKey, order ) ->
            (case columnKey of
                Name ->
                    List.sortWith (\a b -> orderProduct order a.name b.name)

                Power ->
                    List.sortWith (\a b -> orderProduct order a.power b.power)
            )
                gridData

        Nothing ->
            gridData


filterList : String -> List Data -> List Data
filterList lwQuery gridData =
    List.filter
        (\{ name, power } ->
            String.contains lwQuery (String.toLower name)
                || String.contains lwQuery (String.toLower <| toString power)
        )
        gridData



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        }
