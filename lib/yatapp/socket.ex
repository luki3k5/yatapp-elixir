defmodule Yatapp.Socket do
  @moduledoc false

  require Logger
  alias Phoenix.Channels.GenSocketClient
  alias Yatapp.Config
  @behaviour GenSocketClient

  @socket_url "wss://run.yatapp.net/socket/websocket"

  def start_link() do
    GenSocketClient.start_link(
      __MODULE__,
      GenSocketClient.Transport.WebSocketClient,
      @socket_url
    )
  end

  def init(url) do
    {:connect, url, [{"api_token", Config.get(:api_key)}], %{url: url, store: Config.store()}}
  end

  def handle_connected(transport, state) do
    Logger.info("connected to Yata")
    GenSocketClient.join(transport, "translations:#{Config.get(:project_id)}")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected from Yata: #{inspect(reason)}")
    {:connect, state.url, [{"api_token", Config.get(:api_key)}], state}
  end

  def handle_joined(topic, _payload, _transport, state) do
    Logger.info("joined the topic #{topic}")
    {:ok, state}
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.error("join error on the topic #{topic}: #{inspect(payload)}")
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.error("disconnected from the topic #{topic}: #{inspect(payload)}")
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message(
        _topic,
        "new_translation",
        %{"key" => key, "values" => values},
        _transport,
        %{store: store} = state
      ) do
    Enum.each(values, fn %{"lang" => lang, "text" => text} ->
      store.put(locale_key(lang, key), text)
      Logger.info("new translation added: #{lang} => #{key}: #{text}")
    end)

    {:ok, state}
  end

  def handle_message(
        _topic,
        "updated_translation",
        %{"old_key" => key, "new_key" => key, "values" => new_values},
        _transport,
        %{store: store} = state
      ) do
    Enum.each(new_values, fn %{"lang" => lang, "text" => text} ->
      store.put(locale_key(lang, key), text)
      Logger.info("updated translation: #{lang} => #{key}: #{text}")
    end)

    {:ok, state}
  end

  def handle_message(
        _topic,
        "updated_translation",
        %{"old_key" => old_key, "new_key" => new_key, "values" => new_values},
        _transport,
        %{store: store} = state
      ) do
    Enum.each(new_values, fn %{"lang" => lang, "text" => text} ->
      store.delete(locale_key(lang, old_key))
      store.put(locale_key(lang, new_key), text)
      Logger.info("updated translation: #{lang} => #{new_key}: #{text}")
    end)

    {:ok, state}
  end

  def handle_message(
        _topic,
        "deleted_translation",
        %{"key" => key},
        _transport,
        %{store: store} = state
      ) do
    Enum.each(Config.get(:locales), fn locale ->
      store.delete(locale_key(locale, key))
    end)

    Logger.info("translation deleted: key => #{key}")
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("Unhandled message on topic #{topic}: #{event} #{inspect(payload)}")
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.warn("Unhandled reply on topic #{topic}: #{inspect(payload)}")
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting to Yata")
    {:connect, state}
  end

  def handle_info({:join, topic}, transport, state) do
    Logger.info("joining the topic #{topic}")

    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect(reason)}")
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))

      {:ok, _ref} ->
        :ok
    end

    {:ok, state}
  end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect(message)}")
    {:ok, state}
  end

  def handle_call(message, _from, _transport, state) do
    Logger.warn("Unhandled message #{inspect(message)}")
    {:noreply, state}
  end

  defp locale_key(locale, key), do: "#{locale}.#{key}"
end
