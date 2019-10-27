defmodule Data.Schema do
  use Absinthe.Schema
  use Absinthe.Relay.Schema, :modern

  alias Data.ResumeResolver

  import_types(Absinthe.Type.Custom)
  import_types(Data.SchemaTypes)
  import_types(Data.SchemaUser)
  import_types(Data.ResumeGraphqlSchema)
  import_types(Data.Schema.SpokenLanguageGraphqlSchema)

  query do
    node field do
      resolve(fn
        %{type: :resume, id: id}, _ ->
          ResumeResolver.get_resume(id: id)
      end)
    end

    import_fields(:user_query)
    import_fields(:resume_query)
  end

  mutation do
    import_fields(:user_mutation)
    import_fields(:resume_mutation)
    import_fields(:spoken_language_mutation)
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
