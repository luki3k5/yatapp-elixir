[![CircleCI](https://circleci.com/gh/LLInformatics/yatapp-elixir.svg?style=svg)](https://circleci.com/gh/LLInformatics/yatapp-elixir)

# Yatapp

Welcome to Yata integration Hex package, this package will allow you to easy get your translations from http://yatapp.net service.

## Installation

Add `yatapp` to your list of dependencies and to `applications` in `mix.exs`:

```elixir
# mix.exs

def deps do
  [
    {:yatapp, "~> 0.2.1"}
  ]
end

def application do
  [applications: [:yatapp]]
end
```


## Configuration
Package can be used in two ways:
* integration through API
* websocket integration

### API Integration
Add configuration to your `config/config.exs`:

```elixir
# config.exs

config :yatapp,
  api_key: System.get_env("YATA_API_KEY"),
  project_id: System.get_env("YATA_PROJECT_ID"),
  locales: ~w(en),
  translations_format: "yml",
  save_to_path: "priv/locales/",
  root: false,
  strip_empty: false,
  enable_websocket: false
```

API integration allows you to download all translation using mix task:

```bash
$ mix download_translations
```

### Websocket Integration
Add configuration to your `config/config.exs`:

```elixir
# config.exs

config :yatapp,
  api_key: System.get_env("YATA_API_KEY"),
  project_id: System.get_env("YATA_PROJECT_ID"),
  default_locale: "en",
  locales: ~w(en),
  otp_app: :my_app,
  json_parser: Jason,
  store: Yatapp.Store.ETS,
  download_on_start: false,
  save_to_path: "priv/locales/",
  translations_format: "json",
  translation_file_parser: Jason,
  root: false,
  strip_empty: false,
  enable_websocket: true,
  var_prefix: "%{",
  var_suffix: "}",
  fallback: false
```

Websocket integration connects to Yata server and stays open. All changes in translations are auto-fetched to the app.

When app connects to the Yata server for the first time it fetches all translation and saves them to the ets table. Then all actions on translations like create, update and delete are broadcasting information and ets table is updated.

The values for given locale and key can be fetched using `Yatappp.ExI18n` module:

```elixir
# Examples

# en
number: 1
hello_name: "Hello %{name}"

Yatapp.translate("en", "number") #=> 1
Yatapp.translate("en", "hello_name", %{name: "John"}) #=> "Hello John"
```

### Configuration Parameters

| Option | Description | Default | Websocket | API |
| :--    | :--         | :--:    | :--:      | :--: |
| api_key | Organization Settings > Security > API token | | required | required |
| project_id | Organization Settings > Security > Projects > Id | | required | required |
| default_locale | Default locale in your application. | `"en"` | optional | - |
| locales | Supported locales. | `["en"]` | optional | optional |
| otp_app | Used to generate proper path to locale files | | - | - |
| store | Module that implements `Yatapp.Store` | `Yatapp.Store.ETS` | - | - |
| download_on_start | Download all translations when app starts | `false` | - | - |
| json_parser | JSON parser that will be used to parse response from API | | - | required |
| fallback | Fallback to default locale if translation empty. | `false` | optional | - |
| translations_format | Format you wish to get files in, available for now are (yml, js, json, properties, xml, strings, plist) | `"yml"` | - | optional |
| translation_file_parser | Parser that will parse downloaded files | | - | optional |
| save_to_path | A directory where translations will be saved. | `"priv/locales/"` | - | optional |
| root | Download with language as a root element of the translation | `false` | - | optional |
| strip_empty | Generate only keys that have text and skip empty ones | `false` | - | optional |
| enable_websocket | Enable websocket integration | `false` | required | optional |
| var_prefix | Prefix to values in translations. | `%{` | optional | optional |
| var_suffix | Suffix for values in translations. | `}` | optional | optional |
