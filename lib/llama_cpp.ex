defmodule LlamaCPP do
  @moduledoc """
  Documentation for `LlamaCPP`.
  """
  @urls %{
    "mistral_7b" =>
      "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/blob/main/mistral-7b-v0.1.Q4_K_M.gguf",
    "mistral_7b_instruct" =>
      "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/blob/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf"
  }

  defstruct model_name: nil, model_url: nil, cache: ~c"~/.cache/llama_cpp_ex", port: nil

  def start(config = %__MODULE__{}) do
    cache = Path.expand(config.cache)
    :ok = File.mkdir_p(cache)
    :ok = File.mkdir_p("#{cache}/models")

    path = "#{:code.priv_dir(:llama_cpp_ex)}/main"
    port = Port.open({:spawn_executable, path}, [:binary])

    %__MODULE__{port: port}
  end

  def stop(%__MODULE__{port: port}) do
    Port.close(port)
  end
end
