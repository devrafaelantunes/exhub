defmodule ExHub.Live.Test do
  use ExHubWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Phoenix.ConnTest

  import Mox

  #setup :set_mox_global
  setup :verify_on_exit!

  describe "SearchLive '/' route" do
    test "connecting and mounting", %{conn: conn} do
      {:ok, view, html} = live(conn, "/")

      assert html =~ "<h1>Select Language</h1>"
      assert view.module == ExHubWeb.SearchLive

    end

    test "clicking" , %{conn: conn} do
      :sys.replace_state(:server, fn _state -> %{} end)

      expect(ExHub.ServerMock, :request, fn _ ->
        {:ok, [%{name: "ExHub", description: "GitHub Fetcher", stargazers_count: "999999"}]}
      end)

      {:ok, view, _html} = live(conn, "/")

      html = render_click(view, :search, %{"request" => %{"language" => "Elixir"}})

      assert html =~ "Elixir&#39;s repositories ranked by stars"
      assert html =~ "ExHub"
      assert html =~ "GitHub Fetcher"
      assert html =~ "999999"
    end
  end
end
