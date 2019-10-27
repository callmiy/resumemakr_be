defmodule Data.Schema.RatableGraphqlSchema do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.Resolver.RatableResolver

  ######################### START ENUMS RATED OBJECT ###############

  @desc "the acceptable objects that can be rated"
  enum :ratable_type do
    value(:spoken_language)
    value(:supplementary_skill)
  end

  ##################### END ENUM ####################################

  @desc "An object that can be rated"
  object :ratable do
    field :id, non_null(:id)
    field :description, :string
    field :level, :string
    field :resume_id, :id |> non_null()
  end

  @desc "Variables for creating a ratable"
  input_object :create_ratable_input do
    field :description, :string |> non_null()
    field :level, :string
    field :resume_id, :id |> non_null()
    field :ratable_type, non_null(:ratable_type)
  end

  @desc ~S"""
    Mutations on Ratables
  """
  object :ratable_mutations do
    field :create_ratable, :ratable do
      arg(:input, :create_ratable_input |> non_null())
      resolve(&RatableResolver.create/2)
    end
  end
end
