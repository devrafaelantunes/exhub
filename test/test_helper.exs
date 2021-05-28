ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(ExHub.Repo, :manual)
Mox.defmock(ExHubMock, for: ExHub)
Mox.defmock(ExHub.ServerMock, for: ExHub.Server)
