defmodule Yatapp.TranslationsDownloaderTest do
  use ExUnit.Case, async: false
  import Mock

  setup do
    Application.put_env(:yatapp, :save_to_path, "test/fixtures/")
    Application.put_env(:yatapp, :translations_format, "json")
    Application.put_env(:yatapp, :locales, ["en_US"])
    Application.put_env(:yatapp, :project_id, "1")
    Application.put_env(:yatapp, :api_key, "api_key")

    :ok
  end

  test "download/0" do
    with_mocks [
        {
          HTTPoison, [],
          [
            start: fn -> true end,
            get!: fn _url -> %HTTPoison.Response{body: File.read!("test/fixtures/en.json")} end
          ]
        }
      ] do
      assert Yatapp.TranslationsDownloader.download() == :ok
      assert File.read!("test/fixtures/en_US.json") == File.read!("test/fixtures/en.json")
    end
  end

  test "download_and_store/0" do
    with_mocks [
        {
          HTTPoison, [],
          [
            start: fn -> true end,
            get!: fn _url -> %HTTPoison.Response{body: File.read!("test/fixtures/en.json")} end
          ]
        }
      ] do
      assert Yatapp.TranslationsDownloader.download_and_store() == :ok
    end
  end
end
