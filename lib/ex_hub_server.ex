defmodule ExHub.Server do
  alias ExHub.{Results, Repo}
  alias Ecto.Multi
  import Ecto.Query

  use GenServer

  @request_lifetime 30

  def request(language) do
    if Enum.member?(ExHub.languages, language) do
      GenServer.call(:server, {:request, language})
    else
      {:error, :invalid_language}
    end
  end

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, "", name: :server)
  end

  def init(_arg) do
    {:ok, query_results_db()}
  end

  def handle_call({:request, language}, _from, original_state) do
    Multi.new
    |> Multi.run(:state, fn _, _ ->
      if Map.has_key?(original_state, language) do
        {:ok, original_state}
      else
        {:ok, Map.put(original_state, language, %{payload: nil, inserted_at: nil})}
      end
    end)
    |> Multi.run(:current_payload, fn _, %{state: state} ->
      {:ok, state[language].payload}
    end)
    |> Multi.run(:validate_time, fn _, %{state: state} ->
      language_inserted_at = state[language].inserted_at

      if language_inserted_at == nil do
        {:ok, nil}
      else
        time_difference = DateTime.diff(DateTime.utc_now(), language_inserted_at) / 60

        if time_difference > @request_lifetime do
          {:ok, nil}
        else
          {:error, nil}
        end
      end
    end)
    |> Multi.run(:request_payload, fn _, %{current_payload: current_payload} ->
      module = Application.get_env(:ex_hub, :exhub_api)
      %{items: request_payload} = apply(module, :get, [language])

      if request_payload != current_payload do
        {:ok, request_payload}
      else
        {:error, nil}
      end
    end)
    |> Multi.delete_all(:delete, query_by_language(language))
    |> Multi.run(:changeset, fn _, %{request_payload: request_payload} ->
      {:ok, Results.changeset(%{language: language, payload: request_payload})}
    end)
    |> Multi.insert(:result, & &1.changeset)
    |> Multi.run(:new_state, fn _, %{state: state, request_payload: request_payload} ->
      new_state =
        state
        |> Map.delete(language)
        |> Map.put(language, %{payload: request_payload, inserted_at: DateTime.utc_now()})

      {:ok, new_state}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{request_payload: request_payload, new_state: new_state}} ->
        {:reply, request_payload, new_state}

      {:error, _, _reason, %{state: state, current_payload: current_payload}} ->
        {:reply, current_payload, state}
    end
  end

  defp query_results_db() do
    Repo.all(Results)
    |> Enum.reduce(%{}, fn result, acc ->
      Map.put(acc, result.language, %{payload: result.payload, inserted_at: result.inserted_at})
    end)
  end

  def query_by_language(language) do
    from r in Results,
      select: r,
      where: r.language == ^language
  end
end
