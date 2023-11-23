defmodule DemoWeb.ChatLive do
    use DemoWeb, :live_view

    @models [:mistral_7b, :mistral_7b_instruct, :llama2_7b, :orca2_7b]
    @max_prompt_length 128
    
    def render(assigns) do
      ~H"""
        """
    end
    
    def mount(_params, _session, socket) do
        {:ok, socket}
    end
end
