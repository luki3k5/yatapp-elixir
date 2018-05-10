defmodule Mix.Tasks.DownloadTranslations do
  use Mix.Task

  @shortdoc "Downloads all translations from yatapp.net"
  def run(_) do
    Mix.Task.run "app.start"
    Yatapp.TranslationsDownloader.download()
  end
end
