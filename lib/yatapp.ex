defmodule Yatapp do
  @moduledoc """
  Yata integration hex package.
  """
  alias Yatapp.Env

  def start(_type, _args) do
    case Env.get(:enable_websocket) do
      true -> Yatapp.ExI18n.Supervisor.start_link()
      _ ->
        opts = [strategy: :one_for_one, name: Yatapp.Supervisor]
        Supervisor.start_link([], opts)
    end
  end
end
