defmodule Mix.Tasks.DownloadTranslations do
  use Mix.Task

  @shortdoc "Downloads all translations from yatapp.net"
  def run(_) do
    Yatapp.TranslationsDownloader.download()
  end
end
