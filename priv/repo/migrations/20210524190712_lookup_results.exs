defmodule ExHub.Repo.Migrations.LookupResults do
  use Ecto.Migration

  def change do
    create table(:lookup_results) do
      add :language, :string
      add :payload, {:array, :map}

      timestamps()
    end
  end
end
