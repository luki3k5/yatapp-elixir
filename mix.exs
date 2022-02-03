defmodule Yatapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :yatapp,
      version: "0.3.0",
      elixir: "~> 1.12.2",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],

      # Docs
      name: "Yatapp",
      source_url: "https://github.com/LLInformatics/yatapp-elixir",
      homepage_url: "https://github.com/LLInformatics/yatapp-elixir",
      description: "Integrate your translations from Yata.",
      docs: [
        main: "Yatapp",
        extras: ["README.md"]
      ],
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Yatapp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_gen_socket_client, "~> 4.0.0"},
      {:websocket_client, "~> 1.3"},
      {:httpoison, "~> 1.4"},
      {:jason, ">= 1.0.0", only: [:dev, :test]},
      {:ex_doc, "~> 0.24.2", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:mock, "~> 0.3.3", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Łukasz Łażewski"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/LLInformatics/yatapp-elixir"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
