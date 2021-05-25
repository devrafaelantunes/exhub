defmodule ExHubWeb.DisplayLive do
  use ExHubWeb, :live_view

  alias ExHub.Utils

  def handle_params(result, _url, socket) do
    result =
      Utils.atomify_map(result)

    {:noreply,
      socket
      |> assign(:result, result)}
  end
end
