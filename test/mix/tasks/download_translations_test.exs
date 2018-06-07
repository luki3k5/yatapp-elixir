defmodule Mix.Tasks.DownloadTranslationsTest do
  use ExUnit.Case
  import Mock

  setup_with_mocks([
    {:httpc, [],
     [
       request: fn :get, {_url, []}, [], [] ->
         {:ok, {{"HTTP/1.1", 200, 'OK'}, [], File.read!("test/fixtures/en.json")}}
       end
     ]}
  ]) do
    Application.put_env(:yatapp, :save_to_path, "test/fixtures/")
    Application.put_env(:yatapp, :translations_format, "json")
    Application.put_env(:yatapp, :locales, ["en"])

    :ok
  end

  test "run/1" do
    assert Mix.Tasks.DownloadTranslations.run([]) == :ok
  end
end
