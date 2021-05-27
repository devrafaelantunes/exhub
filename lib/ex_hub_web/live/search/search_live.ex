defmodule ExHubWeb.SearchLive do
  use ExHubWeb, :live_view

  alias ExHub.Utils

  @exhub_server Application.get_env(:ex_hub, :exhub_server)

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(:results, %{})
      |> assign(:language, nil)}
  end

  def handle_event("search", %{"request" => %{"language" => language}}, socket) do
    get_response_and_reply(socket, language)
  end

  def handle_params(%{"language" => language} = _params, _url, socket) do
    get_response_and_reply(socket, language)
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp get_response_and_reply(socket, language) do
    {:ok, response} = apply(@exhub_server, :request, [language])
    response = Enum.map(response, fn repository -> Utils.atomify_map(repository) end)

    {:noreply,
      socket
      |> assign(:results, response)
      |> assign(:language, language)}
  end
end
