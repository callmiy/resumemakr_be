defmodule Data.Schema.SpokenLanguageGraphqlSchema do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.Resolver.SpokenLanguage, as: SpokenLanguageResolver

  @desc "A spoken language by a resume owner"
  object :spoken_language do
    field :id, non_null(:id)
    field :description, :string
    field :level, :string
    field :resume_id, :id |> non_null()
  end

  @desc "Variables for creating a language spoken by resume owner"
  input_object :create_spoken_language_input do
    field :description, :string |> non_null()
    field :level, :string
    field :resume_id, :id |> non_null()
  end

  @desc ~S"""
    Mutations on spoken language
  """
  object :spoken_language_mutation do
    field :create_spoken_language, :spoken_language do
      arg(:input, :create_spoken_language_input |> non_null())
      resolve(&SpokenLanguageResolver.create/2)
    end
  end
end
