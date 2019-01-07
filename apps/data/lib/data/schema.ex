defmodule Data.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(Data.SchemaTypes)
  import_types(Data.SchemaCredential)
  import_types(Data.SchemaUser)
  import_types(Data.SchemaResume)

  query do
    import_fields(:user_query)
  end

  mutation do
    import_fields(:user_mutation)
  end

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(
        :data,
        Dataloader.Ecto.new(Data.Repo, query: &my_data/2)
      )

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  def my_data(queryable, _params) do
    queryable
  end
end
