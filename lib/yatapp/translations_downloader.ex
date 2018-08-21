defmodule Yatapp.TranslationsDownloader do
  @moduledoc """
  TranslationsDownloader module.
  """
  alias Yatapp.Env

  @api_version "v1"
  @api_end_point_url "/api/:api_version/project/:project_id/:lang/:format"
  @api_base_url "http://api.yatapp.net"

  @doc """
  Downloads all translations and saves all locales.

  Returns `:ok`.

  ## Examples

      iex> Yatapp.TranslationsDownloader.download()
      :ok

  """
  @spec download() :: :ok
  def download() do
    Enum.each(Env.get(:locales), fn lang ->
      IO.inspect("Getting translation for #{lang}")
      save_file(lang)
      IO.inspect("#{lang}.#{Env.get(:translations_format)} saved")
    end)
  end

  @spec ets_download(String.t()) :: Map.t()
  def ets_download(lang) do
    {:ok, {{_, 200, 'OK'}, _headers, body}} = get_response(lang, "json", true, false)
    Poison.decode!(body)
  end

  defp download_url(lang, format, root, strip_empty) do
    @api_end_point_url
    |> String.replace(":api_version", @api_version)
    |> String.replace(":project_id", Env.get(:project_id))
    |> String.replace(":lang", lang)
    |> String.replace(":format", format)
    |> String.replace_suffix("", "?apiToken=#{Env.get(:api_key)}&root=#{root}&strip_empty=#{strip_empty}")
    |> String.replace_prefix("", @api_base_url)
    |> String.to_charlist()
  end

  defp get_response(lang, format, root, strip_empty) do
    :inets.start()

    :httpc.request(:get, {download_url(lang, format, root, strip_empty), []}, [], [])
  end

  defp save_file(lang) do
    {:ok, {{_, 200, 'OK'}, _headers, body}} =
      get_response(lang, Env.get(:translations_format), Env.get(:root), Env.get(:strip_empty))

    unless File.exists?(Env.get(:save_to_path)) do
      File.mkdir(Env.get(:save_to_path))
    end

    File.write!("#{Env.get(:save_to_path)}#{lang}.#{Env.get(:translations_format)}", body)
  end
end
