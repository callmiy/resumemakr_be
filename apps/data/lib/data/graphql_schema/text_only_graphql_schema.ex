defmodule Data.Schema.TextOnlyGraphqlSchema do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.Resolver.TextOnlyResolver

  ######################### START ENUMS text_only_tag ###############

  @desc "a tag used to identify the owner of text only object"
  enum :text_only_tag do
    value(:resumes_hobbies)
    value(:education_achievements)
    value(:experience_achievements)
    value(:skills_achievements)
  end

  ##################### END ENUM ####################################

  @desc "A text only object"
  object :text_only do
    field :id, non_null(:id)
    field :text, :string |> non_null()
    field :owner_id, :id |> non_null()
  end

  @desc "Variables for creating a text only object"
  input_object :create_text_only_input do
    field :text, :string |> non_null()
    field :owner_id, :id |> non_null()
    field :tag, non_null(:text_only_tag)
  end

  @desc ~S"""
    Mutations on TextOnly objects
  """
  object :text_only_mutations do
    field :create_text_only, :text_only do
      arg(:input, :create_text_only_input |> non_null())
      resolve(&TextOnlyResolver.create/2)
    end
  end
end
