use Mix.Config

config :yatapp,
  api_key: System.get_env("YATA_API_KEY"),
  project_id: System.get_env("YATA_PROJECT_ID"),
  default_locale: "en",
  locales: ~w(en),
  translations_format: "yml",
  save_to_path: "priv/locales/",
  root: false,
  strip_empty: false,
  enable_websocket: false,
  var_prefix: "%{",
  var_suffix: "}",
  fallback: false
