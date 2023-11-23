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
      # make_precompiler_url: "#{@source_url}/releases/download/v#{@version}/@{artefact_filename}",
      make_precompiler_filename: "main",
      make_precompiler_priv_paths: ["main", "server"],
      # Disable to enable prebuilt binaries
      make_force_build: true,
      start_permanent: Mix.env() == :prod,
      package: package(),
      deps: deps()
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
      licenses: ["MIT"],
      links: %{"Git" => @source_url}
    ]
  end

  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:cc_precompiler, "~> 0.1.0",
       runtime: false, github: "cocoa-xu/cc_precompiler", override: false},
      {:req, "~> 0.4.5"}
    ]
  end
end
