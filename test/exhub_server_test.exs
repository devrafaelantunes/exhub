defmodule ExHub.Server.Test do
  use ExHub.DataCase

  alias ExHub.{Repo, Server, Results}
  import Mox

  @language "Elixir"
  @response [%{
    description: :description,
    forks: :forks,
    name: :name
  }]

  setup :set_mox_global
  setup :verify_on_exit!

  #setup do
  #  start_supervised(ExHub.Server)
  #  :ok
  #end

  describe "genserver test" do
    test "getting db results when initializing" do
      IO.inspect :sys.get_state(:server)
    end
  end

  describe "requesting from GitHub API and inserting into the cache + db" do
    test "with valid language" do
      :sys.replace_state(:server, fn _state -> %{} end)

      ExHubMock
      |> expect(:get, fn _ -> %{items: @response} end)

      Server.request(@language)

      assert %{@language => %{inserted_at: _datetime, payload: @response}} = :sys.get_state(:server)
      assert %Results{language: @language, payload: [%{}]} = Server.query_by_language(@language) |> Repo.one()
    end

    test "with invalid language" do
      assert Server.request("Nuuvem") == {:error, :invalid_language}
    end

    test "below request lifetime" do
      :sys.replace_state(:server, fn _state -> %{} end)

      ExHubMock
      |> expect(:get, fn _ -> %{items: @response} end)

      Server.request(@language)
      %{@language => %{inserted_at: first_request_datetime_state}} = :sys.get_state(:server)
      %Results{inserted_at: first_request_datetime_db} = Server.query_by_language(@language) |> Repo.one()

      Server.request(@language)
      %{@language => %{inserted_at: second_request_datetime_state}} = :sys.get_state(:server)
      %Results{inserted_at: second_request_datetime_db} = Server.query_by_language(@language) |> Repo.one()

      assert first_request_datetime_state == second_request_datetime_state
      assert first_request_datetime_db == second_request_datetime_db
    end
  end # falta aqui
end
