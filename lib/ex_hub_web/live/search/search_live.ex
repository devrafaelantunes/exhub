defmodule ExHubWeb.SearchLive do
  use ExHubWeb, :live_view

  alias ExHub.Utils

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:results, %{})
      |> assign(:language, nil)}
  end

  def handle_event("save", %{"request" => %{"language" => language}}, socket) do
    get_response_and_reply(socket, language)
  end

  def handle_params(%{"language" => language} = params, url, socket) do
    get_response_and_reply(socket, language)
  end

  def handle_params(params, url, socket) do
    {:noreply, socket}
  end

  defp get_response_and_reply(socket, language) do
    response =
      GenServer.call(:server, {:request, language})
      |> Enum.map(fn repository -> Utils.atomify_map(repository) end)

    {:noreply,
      socket
      |> assign(:results, response)
      |> assign(:language, language)}
  end
end
