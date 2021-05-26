defmodule ExHub.Test do

  use ExHub.DataCase

  alias ExHub.Repo

  import Mox

  setup :verify_on_exit!
  setup :set_mox_global

  test "get api" do
    IO.inspect(self())
    Repo.all(ExHub.Results)
    |> IO.inspect()

    ExHubMock
    |> expect(:get, fn language ->
      assert language == "Elixir"
      %{items: "Oi"}
    end)

    # #ExHub.Server.start_link(:arg)
    # #|> IO.inspect()

    ExHub.Server.request("Elixir") == %{items: "Oi"}
    |> IO.inspect()
  end



end
