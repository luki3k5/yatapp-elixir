defmodule Yatapp.TranslationsDownloader do
  @moduledoc """
  TranslationsDownloader module.
  """
  require Logger
  alias Yatapp.Config

  @api_end_point_url "https://api.yatapp.net/api/v1/project/:project_id/:lang/:format"

  @doc """
  Downloads all translations and saves all locales.

  Returns `:ok`.

  ## Examples

      iex> Yatapp.TranslationsDownloader.download()
      :ok

  """
  @spec download() :: :ok
  def download() do
    Enum.each(Config.get(:locales), fn lang ->
      Logger.info("Getting translation for #{lang}")
      save_file(lang)
      Logger.info("#{lang}.#{Config.get(:translations_format)} saved")
    end)
  end

  @spec download_and_store() :: :ok
  def download_and_store() do
    Enum.each(Config.get(:locales), fn locale ->
      {:ok, {{_, 200, 'OK'}, _headers, body}} = get_response(locale, "json", true, false)
      parser = Config.get(:json_parser)

      body
      |> parser.decode!()
      |> create_translations(locale)
    end)
  end

  defp create_translations(translations, locale) do
    Enum.each(translations, fn {key, value} -> create_translation("#{locale}.#{key}", value) end)
  end

  defp create_translation(key, value) when is_map(value) do
    Enum.each(value, fn {k, v} -> create_translation("#{key}.#{k}", v) end)
  end

  defp create_translation(key, value) do
    store = Config.store()
    store.put(key, value)
  end

  defp download_url(lang, format, root, strip_empty) do
    @api_end_point_url
    |> String.replace(":project_id", Config.get(:project_id))
    |> String.replace(":lang", lang)
    |> String.replace(":format", format)
    |> String.replace_suffix(
      "",
      "?apiToken=#{Config.get(:api_key)}&root=#{root}&strip_empty=#{strip_empty}"
    )
    |> String.to_charlist()
  end

  defp get_response(lang, format, root, strip_empty) do
    :inets.start()

    :httpc.request(:get, {download_url(lang, format, root, strip_empty), []}, [], [])
  end

  defp save_file(lang) do
    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      get_response(
        lang,
        Config.get(:translations_format),
        Config.get(:root),
        Config.get(:strip_empty)
      )

    unless File.exists?(Config.get(:save_to_path)) do
      File.mkdir(Config.get(:save_to_path))
    end

    File.write!("#{Config.get(:save_to_path)}#{lang}.#{Config.get(:translations_format)}", body)
  end

  @spec load_from_files() :: :ok
  def load_from_files do
    otp_app = Config.get(:otp_app)
    parser = Config.get(:translation_file_parser)

    Enum.each(Config.get(:locales), fn locale ->
      path_to_file = "#{Config.get(:save_to_path)}#{locale}.#{Config.get(:translations_format)}"
      path = Application.app_dir(otp_app, path_to_file)

      if File.exists?(path) do
        path
        |> File.read!()
        |> parser.decode!()
        |> create_translations(locale)
      end
    end)
  end
end
