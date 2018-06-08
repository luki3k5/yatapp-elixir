defmodule Yatapp.MixProject do
  use Mix.Project

  def project do
    [
      app: :yatapp,
      version: "0.1.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
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
      {:phoenix_gen_socket_client, "~> 2.1.1"},
      {:websocket_client, "~> 1.2"},
      {:poison, "~> 2.0"},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.8.2", only: :test},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end

  defp package do
    [
      files: ["lib", "config", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Katarzyna Kobierska"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/LLInformatics/yatapp-elixir"}
    ]
  end
end
