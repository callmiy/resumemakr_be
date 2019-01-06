Absinthe.Test.prime(Data.Schema)
ExUnit.start(exclude: [integration: true, db: true])
Ecto.Adapters.SQL.Sandbox.mode(Data.Repo, :manual)
