defmodule Data.TextOnlyGraphqlSchemaTest do
  use Data.DataCase

  alias Data.ResumeFactory
  alias Data.RegistrationFactory
  alias Data.TextOnlyFactory
  alias Data.TextOnlyQuery
  alias Data.Schema
  alias Data.EducationFactory

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

  describe "education achievements" do
    test "create succeeds" do
      user = RegistrationFactory.insert()
      resume = ResumeFactory.insert(user_id: user.id)
      education = EducationFactory.insert(resume_id: resume.id)

      variables = %{
        "input" =>
          TextOnlyFactory.params(
            owner_id: education.id,
            tag: :education_achievements
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
