defmodule LlamaCPP.MixProject do
  use Mix.Project

  @version "0.1.0"
  @description "Elixir wrapper for llama.cpp."
  @source_url "https://github.com/mvkvc/llama_cpp_ex"

  def project do
    [
      app: :llama_cpp,
      version: @version,
      description: @description,
      elixir: "~> 1.15",
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_precompiler: {:port, CCPrecompiler},
      make_precompiler_url: "#{@source_url}/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_filename: "main",
      make_precompiler_priv_paths: ["main.*"],
      # Disable to enable prebuilt binaries
      make_force_build: true,
      start_permanent: Mix.env() == :prod,
      package: package(),
      docs: docs(),
      dialyzer: dialyzer(),
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {LlamaCPP.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      # licenses: ["MIT"],
      links: %{"Git" => @source_url}
    ]
  end

  defp docs do
    md_files = File.ls!("./docs")
                |> Enum.filter(&String.ends_with?(&1, ".md"))
                |> Enum.map(&Path.expand("./docs/#{&1}"))

    [
      extras: [{:"README.md", [title: "Overview"]}|md_files],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "plts",
      plt_file: {:no_warn, "plts/dialyzer.plt"}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:cc_precompiler, "~> 0.1.0", runtime: false, github: "cocoa-xu/cc_precompiler", override: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      lint: [
        "credo --mute-exit-status",
        "dialyzer --ignore-exit-status",
        "format --check-formatted"
      ],
      docs: ["docs --formatter html"]
    ]
  end
end
