defmodule Mix.Tasks.DownloadTranslations do
  @moduledoc false
  use Mix.Task

  def run(_) do
    Yatapp.TranslationsDownloader.download()
  end
end
