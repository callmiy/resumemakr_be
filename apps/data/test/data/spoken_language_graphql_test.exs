defmodule Data.SpokenLanguageGraphqlTest do
  use Data.DataCase

  alias Data.Schema
  alias Data.SpokenLanguageFactory
  alias Data.RegistrationFactory
  alias Data.ResumeFactory
  alias Data.SpokenLanguageQuery

  describe "create" do
    test "succeeds - graphql" do
      user = RegistrationFactory.insert()
      resume = ResumeFactory.insert_minimal(user_id: user.id)
      resume_id = resume.id |> to_string()

      variables = %{
        "input" =>
          SpokenLanguageFactory.params(resume_id: resume_id)
          |> SpokenLanguageFactory.stringify()
      }

      SpokenLanguageFactory.params(resume_id: resume.id)
      |> SpokenLanguageFactory.stringify()

      assert {
               :ok,
               %{
                 data: %{
                   "createSpokenLanguage" => %{
                     "id" => _,
                     "resumeId" => ^resume_id
                   }
                 }
               }
             } =
               Absinthe.run(
                 SpokenLanguageQuery.create(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  def context(user) do
    %{
      current_user: user
    }
  end
end
