defmodule LlamaCPP.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: LlamaCPP.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: LlamaCPP.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
