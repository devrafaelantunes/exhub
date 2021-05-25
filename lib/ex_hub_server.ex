defmodule ExHub.Server do
  alias ExHub.Results.Query
  alias ExHub.Internal
  alias Ecto.Multi
  alias ExHub.{Repo, Utils}

  use GenServer

  @minutes 30

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, "", name: :server)
  end

  def init(_arg) do
    {:ok, Query.results()}
  end

  def handle_call({:request, language}, _from, state) do
    if Map.has_key?(state, language) do
      payload =
        Map.get(state, language)
        |> atomify_data()

      datetime =
        Map.get(state, language)
        |> Map.get(:inserted_at)


      verificate_request(payload, datetime, language, state)
    else
      %{items: results} = ExHub.get(language)

      state = Map.put(state, language, %{payload: results, inserted_at: DateTime.utc_now()})
      Internal.insert(%{language: language, payload: results})

      {:reply, results, state}
    end
  end

  defp verificate_request(payload, datetime, language, state) do
    Multi.new
    |> Multi.run(:validate_time, fn _, _ ->
      IO.puts("Checking time...")

      time_difference =
        DateTime.diff(DateTime.utc_now(), datetime) / 60

      if time_difference > @minutes do
        {:ok, nil}
      else
        {:error, nil}
      end
    end)
    |> Multi.run(:validate_replacement, fn _, _ ->
      IO.puts("Checking if they are the same...")

      %{items: requested_payload} = ExHub.get(language)

      if requested_payload ==! payload do
        {:ok, requested_payload}
      else
        {:error, nil}
      end
    end)
    |> Multi.run(:delete, fn _, _ ->
      IO.puts("Deleting...")

      Internal.delete_result_by_language(language)

      {:ok, :deleted}
    end)
    |> Multi.run(:insert, fn _, %{validate_replacement: requested_payload} ->
      IO.puts("Inserting...")

      Internal.insert(%{language: language, payload: requested_payload})

      state =
        state
        |> Map.delete(language)
        |> Map.put(language, %{payload: requested_payload, inserted_at: DateTime.utc_now()})

      {:ok, {state, requested_payload}}

    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert: {state, requested_payload}}} -> {:reply, requested_payload, state}
      {:error, _, reason, _} -> {:reply, payload, state}
    end
  end

  defp atomify_data(payload) do
    Enum.map(Map.get(payload, :payload), fn item ->
      Utils.atomify_map(item)
    end)
  end
end
