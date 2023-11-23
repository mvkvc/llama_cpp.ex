defmodule LlamaCPP do
  @moduledoc """
  Documentation for `LlamaCPP`.
  """
  alias LlamaCPP.Wrapper

  # TODO: Download to folder outside of deps or _build to somethign like ~/.lce/models

  @models %{
    "mistral_7b" =>
      "https://huggingface.co/TheBloke/Mistral-7B-v0.1-GGUF/resolve/main/mistral-7b-v0.1.Q4_K_M.gguf?download=true",
      
    "mistral_7b_instruct" =>
      "https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.1-GGUF/resolve/main/mistral-7b-instruct-v0.1.Q4_K_M.gguf?download=true",
    # "llama2_7b" =>
    #   "https://huggingface.co/TheBloke/Llama-2-7B-GGUF/blob/main/llama-2-7b.Q4_K_M.gguf",
    # "orca2_7b" => "https://huggingface.co/TheBloke/Orca-2-7B-GGUF/blob/main/orca-2-7b.Q4_K_M.gguf"
  }

  def path_models, do: "#{:code.priv_dir(:llama_cpp)}/models"

  def server(model) do
    case get_model(model) do
      {:ok, path} ->
        System.cmd("#{:code.priv_dir(:llama_cpp)}/server)", ["-m", path])

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_model(model) do
    url = Map.fetch!(@models, model)
    filename = url |> String.split("/") |> Enum.at(-1) |> String.split("?") |> Enum.at(0)
    if !File.exists?(LlamaCPP.path_models()), do: File.mkdir_p(LlamaCPP.path_models())
    path = LlamaCPP.path_models() <> "/" <> filename
    check_and_download(path, url)
  end

  def check_and_download(path, url) do
    if File.exists?(path) do
      {:ok, path}
    else
      case Req.get(url) do
        {:ok, response} ->
          File.write!(path, response.body)
          {:ok, path}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def completion(prompt, model, args \\ []) do
    args = Keyword.put(args, :prompt, prompt)
    args = Keyword.put(args, :model, model)
    args = Keyword.put(args, :pid, self())
    timeout = Keyword.get(args, :timeout, 30_000)

    # Define the child specification for the GenServer
    child_spec = {Wrapper, args}

    # Start the GenServer under the dynamic supervisor
    case DynamicSupervisor.start_child(LlamaCPP.DynamicSupervisor, child_spec) do
      {:ok, pid} ->
        Process.send_after(self(), :timeout, timeout)

        receive do
          {:output_complete, :error} ->
            {:error, :port}

          {:output_complete, result} ->
            {:ok, result}

          {:timeout} ->
            Process.send(pid, :timeout, [])
            {:error, :timeout}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  # def stream() do
  # end
end
