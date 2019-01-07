defmodule Data.SchemaResumeTest do
  use Data.DataCase

  alias Data.Schema
  alias Data.FactoryResume, as: Factory
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryResume, as: Query
  alias Data.Resumes

  @moduletag :db

  describe "mutation" do
    test "create resume succeeds" do
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

    test "title is made unique" do
      user = RegFactory.insert()
      title = Faker.Lorem.word()

      assert {
               :ok,
               _resume
             } = Resumes.create_resume(%{title: title, user_id: user.id})

      variables = %{
        "resume" => %{"title" => title}
      }

      assert {:ok,
              %{
                data: %{
                  "resume" => %{
                    "title" => title_from_db
                  }
                }
              }} =
               Absinthe.run(
                 Query.create_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )

      assert Regex.compile!("^#{title}_\\d{10}$") |> Regex.match?(title_from_db)
    end
  end

  defp context(user), do: %{current_user: user}
end
