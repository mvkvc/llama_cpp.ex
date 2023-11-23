defmodule LlamaCPP.Wrapper do
  use GenServer

  def build_cmd_args(opts \\ []) do
    with {:ok, model} = Keyword.fetch(opts, :model),
         {:ok, prompt} = Keyword.fetch(opts, :prompt),
         {:ok, model_path} <- LlamaCPP.get_model(model) do
      tokens = Keyword.get(opts, :tokens, 128)
      context = Keyword.get(opts, :context)

      cmd_args =
        []
        |> Enum.concat()
        |> opt_append(model, ["-m", "#{model_path}"])
        |> opt_append(tokens, ["-n", "%%"])
        |> opt_append(context, ["-c", "%%"])
        |> opt_append(prompt, ["-p", "%%"])

      {:ok, cmd_args}
    else
      # More specific error handling
      {:error, reason} -> {:error, reason}
    end
  end

  defp opt_append(cmd_args, value, template) do
    if value != nil do
      new_ending = Enum.map(template, fn text -> String.replace(text, "%%", to_string(value)) end)
      cmd_args ++ new_ending
    else
      cmd_args
    end
  end

  def start_link(args \\ [], opts \\ []) do
    GenServer.start_link(__MODULE__, args, opts)
  end

  def init(args \\ []) do
    case build_cmd_args(args) do
      {:ok, cmd_args} ->
        cmd = "#{:code.priv_dir(:llama_cpp)}/main"
        port = Port.open({:spawn_executable, cmd}, [:binary, :exit_status, args: cmd_args])

        {:ok, %{output: "", exit_status: nil, port: port}}

      {:error, _reason} = error ->
        {:stop, error}
    end
  end

  def handle_info({_port, {:data, text_line}}, state) do
    %{output: output, pid: pid} = state
    latest_output = output <> text_line

    send_if_pid(pid, {:output_update, latest_output})

    {:noreply, %{state | output: latest_output}}
  end

  def handle_info({_, {:exit_status, status}}, %{output: output, pid: pid} = state) do
    case status do
      0 -> send_if_pid(pid, {:output_complete, output})
      1 -> send_if_pid(pid, {:output_complete, :error})
    end

    new_state = %{state | exit_status: status}
    {:noreply, new_state}
  end

  def handle_info(:timeout, %{port: port} = state) do
    Port.close(port)
    {:stop, :timeout, state}
  end

  def handle_info(_msg, state), do: {:noreply, state}

  defp send_if_pid(pid, message) do
    if pid do
      Process.send(pid, message, [])
    else
      IO.puts(message)
    end
  end
end
