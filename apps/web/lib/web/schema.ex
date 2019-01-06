defmodule Web.Schema do
  use Absinthe.Schema

  import_types(Absinthe.Type.Custom)
  import_types(Web.SchemaTypes)
  import_types(Web.SchemaCredential)
  import_types(Web.SchemaUser)

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
