defmodule ExHub do

  @type language() :: String.t()
  @callback get(language) :: map | {:error, String.t()}
  def get(language, headers \\ []) do
    language
    |> call(headers)
    |> content_type
    |> decode
  end

  defp call(language, headers) do
    "https://api.github.com/search/repositories?q=language:#{language}&sort=stars&order_by=desc&per_page=1"
    |> HTTPoison.get(headers)
    |> case do
         {:ok, %{body: raw, status_code: code, headers: headers}} ->
           {code, raw, headers}
         {:error, %{reason: reason}} -> {:error, reason, []}
      end
  end

  defp content_type({ok, body, headers}) do
    {ok, body, content_type(headers)}
  end

  defp content_type([{"Content-Type", val} | _]) do
    val
    |> String.split(";")
    |> List.first
  end

  defp content_type([_ | t]), do: content_type(t)

  defp decode({_ok, body, "application/json"}) do
    body
    |> Poison.decode(keys: :atoms)
    |> case do
         {:ok, %{items: items} = _parsed} -> %{items: items}
         _ -> {:error, body}
       end
  end

  defp decode({ok, body, _}), do: {ok, body}

end
