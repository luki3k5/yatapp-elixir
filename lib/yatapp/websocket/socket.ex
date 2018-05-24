defmodule Yatapp.SocketClient do
  @moduledoc false
  require Logger

  alias Phoenix.Channels.GenSocketClient
  alias Yatapp.Env

  @behaviour GenSocketClient
  @table :exi18n_translations

  def start_link() do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      "ws://8b43a2ac.ngrok.io/socket/websocket"
    )
  end

  def init(url) do
    {:connect, url, [{"api_token", Env.get(:api_key)}], %{first_join: true, ping_ref: 1}}
  end

  def handle_connected(transport, state) do
    Logger.info("connected")
    :ets.new(@table, [:named_table, :protected])
    GenSocketClient.join(transport, "translations:#{Env.get(:project_id)}")
    {:ok, state}
  end

  def handle_disconnected(reason, state) do
    Logger.error("disconnected: #{inspect(reason)}")
    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  def handle_joined(topic, _payload, _transport, state) do
    Logger.info("joined the topic #{topic}")
    load_translations()

    if state.first_join do
      # :timer.send_interval(:timer.seconds(1), self(), :ping_server)
      {:ok, %{state | first_join: false, ping_ref: 1}}
    else
      {:ok, %{state | ping_ref: 1}}
    end
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

  def handle_message(_topic, "new_translation", %{"key" => key, "values" => values}, _transport, state) do
    add_new_keys_to_ets(key, values)
    {:ok, state}
  end

  def handle_message(_topic, "updated_translation", %{"old_key" => old_key, "new_key" => new_key, "values" => new_values}, _transport, state) do
    update_keys(old_key, new_key, new_values)
    {:ok, state}
  end

  def handle_message(_topic, "deleted_translation", %{"key" => key}, _transport, state) do
    remove_translation(key)
    Logger.info("translation deleted: key => #{key}")
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    Logger.warn("message on topic #{topic}: #{event} #{inspect(payload)}")
    {:ok, state}
  end

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    Logger.info("server pong ##{payload["response"]["ping_ref"]}")
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    Logger.warn("reply on topic #{topic}: #{inspect(payload)}")
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.info("connecting")
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

  def handle_info(:ping_server, transport, state) do
    Logger.info("sending ping ##{state.ping_ref}")
    GenSocketClient.push(transport, "ping", "ping", %{ping_ref: state.ping_ref})
    {:ok, %{state | ping_ref: state.ping_ref + 1}}
  end

  def handle_info(message, _transport, state) do
    Logger.warn("Unhandled message #{inspect(message)}")
    {:ok, state}
  end

  def handle_call({:get_translation, locale, key}, _from, state) do
    new_key = locale_key(locale, key)
    translation =
      case :ets.lookup(@table, new_key) do
        [{_, translation}] -> translation
        [] -> []
      end

    {:reply, translation, state}
  end

  def get_translation(locale, key) do
    GenServer.call(__MODULE__, {:get_translation, locale, key})
  end

  defp load_translations() do
    Enum.each(Env.get(:locales), fn locale ->
      Yatapp.TranslationsDownloader.ets_download(locale)
      |> create_translations()
    end)
  end

  defp create_translations(map) do
    Enum.map(map, fn {key, value} ->
      create_translation(key, value)
    end)
  end

  defp create_translation(key, value)
       when is_map(value) do
    Enum.map(value, fn {k, v} ->
      key = Enum.join([key, k], ".")
      create_translation(key, v)
    end)
  end

  defp create_translation(key, value) do
    :ets.insert(@table, {key, value})
  end

  defp add_new_keys_to_ets(key, values) do
    Enum.each(values, fn %{"lang" => lang, "text" => text} ->
      locale_key(lang, key) |> create_translation(text)
      Logger.info("new translation added: #{lang} => #{key}: #{text}")
    end)
  end

  defp update_keys(old_key, new_key, new_values) do
    Enum.each(new_values, fn %{"lang" => lang, "text" => text} ->
     case old_key == new_key do
        true ->
          locale_key(lang, new_key) |> create_translation(text)
          Logger.info("updated translation: #{lang} => #{new_key}: #{text}")
        false ->
          locale_key(lang, old_key) |> remove_translation()
          locale_key(lang, new_key) |> create_translation(text)
          Logger.info("updated translation: #{lang} => #{new_key}: #{text}")
     end
    end)
  end

  defp locale_key(locale, key) do
    Enum.join([locale, key], ".")
  end

  defp remove_translation(key) do
    :ets.take(@table, key)
  end
end
