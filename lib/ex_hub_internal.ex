defmodule ExHub.Internal do
  alias ExHub.{Results, Repo, Results.Query}

  def insert(attrs) do
    Results.changeset(attrs)
    |> Repo.insert()
  end

  def fetch_results() do
    Repo.all(Results)
  end

  def delete_result_by_language(language) do
    Query.by_language(language)
    |> Repo.one()
    |> Repo.delete()
  end
end
