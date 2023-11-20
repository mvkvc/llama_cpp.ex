defmodule LlamaCpp.Server do
  use GenServer

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  def start(config) do
    GenServer.start(__MODULE__, config, name: __MODULE__)
  end

  def stop do
    GenServer.stop(__MODULE__)
  end
end
