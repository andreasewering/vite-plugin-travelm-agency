module DynamicMain exposing (..)

import Browser
import DynamicTranslations as Translations exposing (I18n, Language)
import Html exposing (Html)
import Html.Events
import Http
import Json.Decode as D


type Msg
    = SwitchLanguage Language
    | LoadedTranslations (Result Http.Error (I18n -> I18n))


type alias Flags =
    D.Value


type alias Model =
    { i18n : I18n, activeLanguage : Language }


main : Program Flags Model Msg
main =
    Browser.document
        { init =
            \translations ->
                ( { i18n =
                        Translations.init
                            |> (case D.decodeValue Translations.decodeMessages translations of
                                    Ok addTranslations ->
                                        addTranslations

                                    Err err ->
                                        identity
                               )
                  , activeLanguage = Translations.En
                  }
                , Cmd.none
                )
        , update =
            \msg model ->
                case msg of
                    SwitchLanguage lang ->
                        ( { model | activeLanguage = lang }, Translations.loadMessages { language = lang, path = "/i18n", onLoad = LoadedTranslations } )

                    LoadedTranslations (Ok addTranslations) ->
                        ( { model | i18n = addTranslations model.i18n }, Cmd.none )

                    LoadedTranslations (Err _) ->
                        ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        , view =
            \{ i18n } ->
                { title = "Vite Plugin"
                , body =
                    [ Html.span [] [ Html.text <| Translations.testMessage i18n ]
                    ]
                        ++ List.map switchLanguageButton Translations.languages
                }
        }


switchLanguageButton : Language -> Html Msg
switchLanguageButton lang =
    Html.button [ Html.Events.onClick (SwitchLanguage lang) ] [ Html.text <| Translations.languageToString lang ]
