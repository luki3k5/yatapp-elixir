defmodule Yatapp.Supervisor do
  @moduledoc false
  use Supervisor
  alias Yatapp.Config

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    {store, store_options} = Config.store_and_options()
    store.init(store_options)

    if Config.get(:download_on_start) do
      Yatapp.TranslationsDownloader.download_and_store()
    else
      Yatapp.TranslationsDownloader.load_from_files()
    end

    children =
      if Config.get(:enable_websocket) do
        [worker(Yatapp.Socket, []), worker(Yatapp.TranslationsSynchronizer, [])]
      else
        [worker(Yatapp.TranslationsSynchronizer, [])]
      end

    supervise(children, strategy: :one_for_one)
  end
end
