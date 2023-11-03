defmodule Yatapp.TranslationsSynchronizer do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def synchronize(pid) do
    GenServer.cast(pid, :synchronize)
  end

  def init(state) do
    {:ok, %{last_time_translations_fetched: nil}}
  end

  def handle_cast(:synchronize, %{last_time_translations_fetched: nil}) do
    fetch_translations()
    {:noreply, %{last_time_translations_fetched: DateTime.utc_now()}} |> IO.inspect()
  end

  def handle_cast(:synchronize, state) do
    now = DateTime.utc_now()
    elapsed_time = DateTime.diff(now, state.last_time_translations_fetched)
    ten_minutes = 10 * 60

    if elapsed_time > ten_minutes do
      fetch_translations()
      {:noreply, %{last_time_translations_fetched: now}}
    else
      {:noreply, state}
    end
  end

  defp fetch_translations do
    if Yatapp.Config.get(:download_on_start) do
      Yatapp.TranslationsDownloader.download_and_store()
    end
  end
end
