defmodule ExHub.Results do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lookup_results" do
    field :language, :string
    field :payload, {:array, :map}

    timestamps([type: :utc_datetime_usec])
  end

  def changeset(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:language, :payload])
    |> validate_required([:language, :payload])
  end
end

defmodule ExHub.Results.Query do
  import Ecto.Query
  alias ExHub.{Results, Internal}

  def results() do
    Internal.fetch_results()
    |> Enum.reduce(%{}, fn result, acc ->
      Map.put(acc, result.language, %{payload: result.payload, inserted_at: result.inserted_at})
    end)
  end

  def by_language(language) do
    from r in Results,
      select: r,
      where: r.language == ^language
  end
end
