defmodule ExHub.Behaviour do
  @type language() :: String.t()

  @callback get(language) :: {:ok, integer()}

end
