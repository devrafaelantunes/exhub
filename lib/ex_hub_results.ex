defmodule ExHub.Results do
  use Ecto.Schema
  import Ecto.{Changeset, Query}

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

  def query_by_language(language) do
    from r in __MODULE__,
      select: r,
      where: r.language == ^language
  end
end
