defmodule Yatapp.TranslationsDownloader do
  @moduledoc """
  TranslationsDownloader module.
  """

  @api_version "v1"
  @api_end_point_url "/api/:api_version/project/:project_id/:lang/:format"
  @api_base_url "http://api.yatapp.net"

  @api_key Application.get_env(:yatapp, :api_key, nil)
  @project_id Application.get_env(:yatapp, :project_id, nil)
  @languages Application.get_env(:yatapp, :languages, ~w(en))
  @translation_format Application.get_env(:yatapp, :translations_format, "yml")
  @save_to_path Application.get_env(:yatapp, :save_to_path, "priv/locales/")

  @doc """
  Downloads all translations and saves all locales.

  Returns `:ok`.

  ## Examples

      iex> Yatapp.TranslationsDownloader.download()
      :ok

  """
  def download() do
    Enum.each(@languages, fn lang ->
      IO.inspect("Getting translation for #{lang}")
      save_file(lang)
      IO.inspect("#{lang}.yata.#{@translation_format} saved")
    end)
  end

  defp download_url(lang) do
    @api_end_point_url
    |> String.replace(":api_version", @api_version)
    |> String.replace(":project_id", @project_id)
    |> String.replace(":lang", lang)
    |> String.replace(":format", @translation_format)
    |> String.replace_suffix("", "?apiToken=#{@api_key}")
    |> String.replace_prefix("", @api_base_url)
    |> String.to_charlist()
  end

  defp save_file(lang) do
    :inets.start()

    unless File.exists?(@save_to_path) do
      File.mkdir(@save_to_path)
    end

    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      :httpc.request(:get, {download_url(lang), []}, [], [])

    File.write!("#{@save_to_path}#{lang}.yata.#{@translation_format}", body)
  end
end
