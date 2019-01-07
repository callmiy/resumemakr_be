defmodule Data.SchemaUserTest do
  use Data.DataCase

  alias Data.Schema
  alias Data.FactoryResume, as: Factory
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryResume, as: Query

  @moduletag :db

  describe "mutation" do
    test "creating resume" do
      user = RegFactory.insert()

      attrs =
        Factory.params()
        |> Factory.stringify()

      variables = %{
        "resume" => attrs
      }

      assert {:ok,
              %{
                data: %{
                  "resume" => %{
                    "title" => _,
                    "description" => _,
                    "personalInfo" => _,
                    "experiences" => _,
                    "education" => _
                  }
                }
              }} =
               Absinthe.run(
                 Query.create_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  defp context(user), do: %{current_user: user}
end
