defmodule ExHub.Server do
  alias ExHub.Results.Query
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, "", name: :server)
  end

  def init(_arg) do
    {:ok, Query.get_results()}
  end

  def handle_call({:request, language}, _from, state) do
    %{items: results} = ExHub.get(language)

    state = Map.put(state, language, %{payload: results})

    ## ver como colocar no banco de dados

    {:reply, state, state}
  end

  #{:reply, reply, new_state}

  def handle_cast({:remove_state, attrs}, state) do
    state = state ++ [attrs]

    {:noreply, state}
  end
end
