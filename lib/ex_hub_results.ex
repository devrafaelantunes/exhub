defmodule ExHub.Results do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lookup_results" do
    field :language, :string
    field :payload, :map

    timestamps()
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:language, :payload])
    |> validate_required([:language, :payload])
  end
end

defmodule ExHub.Results.Query do
  import Ecto.Query
  alias ExHub.{Repo, Results}

  def get_results() do
    Repo.all(Results)
    |> Enum.reduce(%{}, fn result, acc ->
      Map.put(acc, result.language, %{payload: result.payload, inserted_at: result.inserted_at})
    end)
  end
end

# [%{language: :a, payload: :payload_a}, %{language: :b, payload: :payload_b}]
# %{a: %{payload: :payload_a}, b: %{payload: :payload_b}}
