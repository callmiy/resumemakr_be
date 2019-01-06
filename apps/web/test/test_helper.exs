Absinthe.Test.prime(Web.Schema)
ExUnit.start(exclude: [integration: true, db: true])
Ecto.Adapters.SQL.Sandbox.mode(Data.Repo, :manual)
