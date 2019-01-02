defmodule Mix.Tasks.Yatapp.DownloadTranslations do
  @moduledoc """
  Downloads translations for all locales defined in config and saves as files.
  """
  use Mix.Task

  @shortdoc "Downloads and saves translations."

  def run(_) do
    Yatapp.TranslationsDownloader.download()
  end
end
