defmodule Yatapp.TranslationsDownloaderTest do
  use ExUnit.Case
  import Mock

  setup_with_mocks([
    {:httpc, [],
      [request: fn(:get, {_url, []}, [], []) -> {:ok, {{"HTTP/1.1", 200, 'OK'}, [], File.read!("test/fixtures/en.json")}} end
      ]},
    ]) do
    Application.put_env(:yatapp, :save_to_path, "test/fixtures/")
    Application.put_env(:yatapp, :translations_format, "json")
    Application.put_env(:yatapp, :locales, ["en"])

    :ok
  end

  test "download/0 with mock" do
    assert Yatapp.TranslationsDownloader.download() == :ok
    assert File.read!("test/fixtures/en.yata.json") == File.read!("test/fixtures/en.json")
  end

  test "ets_download with mock" do
    assert Yatapp.TranslationsDownloader.ets_download("en") == File.read!("test/fixtures/en.json") |> Poison.decode!()
  end
end
