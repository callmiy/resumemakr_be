defmodule Data.RatableGraphqlTest do
  use Data.DataCase

  alias Data.Schema
  alias Data.RatableFactory
  alias Data.RegistrationFactory
  alias Data.ResumeFactory
  alias Data.RatableQuery

  describe "create spoken languages" do
    test "succeeds - graphql" do
      user = RegistrationFactory.insert()
      resume = ResumeFactory.insert_minimal(user_id: user.id)
      owner_id = resume.id

      variables = %{
        "input" =>
          RatableFactory.params(
            owner_id: owner_id,
            ratable_type: :spoken_language
          )
          |> RatableFactory.stringify()
      }

      assert {
               :ok,
               %{
                 data: %{
                   "createRatable" => %{
                     "id" => _,
                     "ownerId" => ^owner_id
                   }
                 }
               }
             } =
               Absinthe.run(
                 RatableQuery.create(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  describe "create supplementary skill" do
    test "succeeds - graphql" do
      user = RegistrationFactory.insert()
      resume = ResumeFactory.insert_minimal(user_id: user.id)
      owner_id = resume.id

      variables = %{
        "input" =>
          RatableFactory.params(
            owner_id: owner_id,
            ratable_type: :supplementary_skill
          )
          |> RatableFactory.stringify()
      }

      assert {
               :ok,
               %{
                 data: %{
                   "createRatable" => %{
                     "id" => _,
                     "ownerId" => ^owner_id
                   }
                 }
               }
             } =
               Absinthe.run(
                 RatableQuery.create(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  defp context(user) do
    %{
      current_user: user
    }
  end
end