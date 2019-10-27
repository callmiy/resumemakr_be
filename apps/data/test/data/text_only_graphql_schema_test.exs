defmodule Data.TextOnlyGraphqlSchemaTest do
  use Data.DataCase

  alias Data.ResumeFactory
  alias Data.RegistrationFactory
  alias Data.TextOnlyFactory
  alias Data.TextOnlyQuery
  alias Data.Schema

  describe "resumes hobbies" do
    test "create succeeds" do
      user = RegistrationFactory.insert()
      resume = ResumeFactory.insert(user_id: user.id)

      variables = %{
        "input" =>
          TextOnlyFactory.params(
            owner_id: resume.id,
            tag: :resumes_hobbies
          )
          |> TextOnlyFactory.stringify()
      }

      assert {
               :ok,
               %{
                 data: %{
                   "createTextOnly" => %{
                     "id" => _,
                     "text" => _,
                     "ownerId" => _
                   }
                 }
               }
             } =
               Absinthe.run(
                 TextOnlyQuery.create(),
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
