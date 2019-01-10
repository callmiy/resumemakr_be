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
        "input" => attrs
      }

      description = attrs["description"]
      title = attrs["title"]

      assert {:ok,
              %{
                data: %{
                  "createResume" => %{
                    "resume" => %{
                      "id" => _id,
                      "_id" => _,
                      "title" => ^title,
                      "description" => ^description,
                      "personalInfo" => personal_info,
                      "experiences" => experiences,
                      "education" => education,
                      "skills" => skills,
                      "additionalSkills" => additional_skills,
                      "languages" => languages
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.create_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )

      assert_assoc(attrs["experiences"] || [], experiences)
      assert_assoc(personal_info, attrs["personalInfo"])
      assert_assoc(education, attrs["education"] || [])
      assert_assoc(languages, attrs["languages"] || [])
      assert_assoc(skills, attrs["skills"] || [])
      assert_assoc(additional_skills, attrs["additionalSkills"] || [])
    end

    test "title is made unique" do
      user = RegFactory.insert()
      title = Faker.Lorem.word()

      assert {
               :ok,
               _resume
             } = Resumes.create_resume(%{title: title, user_id: user.id})

      variables = %{
        "input" => %{"title" => title}
      }

      assert {:ok,
              %{
                data: %{
                  "createResume" => %{
                    "resume" => %{
                      "title" => title_from_db
                    }
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

    test "update resume succeeds" do
      user = RegFactory.insert()

      %{title: title, id: id_} = resume = Factory.insert(user_id: user.id)

      id_ = Integer.to_string(id_)

      update_attrs =
        Factory.params(
          id: Absinthe.Relay.Node.to_global_id(:resume, id_, Schema),
          title: title
        )

      updated_resume_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => updated_resume_str
      }

      context = context(user)

      new_description = updated_resume_str["description"]

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "id" => _id,
                      "_id" => ^id_,
                      "title" => ^title,
                      "description" => ^new_description,
                      "personalInfo" => personal_info,
                      "experiences" => experiences,
                      "education" => education,
                      "skills" => skills,
                      "additionalSkills" => additional_skills,
                      "languages" => languages
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 variables: variables,
                 context: context
               )

      {_, augmented_attrs} = Resumes.augment_attrs(resume, update_attrs)
      augmented_attrs_str = Factory.stringify(augmented_attrs)

      assert_assoc(augmented_attrs_str["experiences"] || [], experiences)
      assert_assoc(personal_info, augmented_attrs_str["personalInfo"])
      assert_assoc(education, augmented_attrs_str["education"] || [])
      assert_assoc(languages, augmented_attrs_str["languages"] || [])
      assert_assoc(skills, augmented_attrs_str["skills"] || [])
      assert_assoc(additional_skills, augmented_attrs_str["additionalSkills"] || [])
    end

    test "update resume fails for unknown user" do
      user = RegFactory.insert()
      context = context(user)
      Factory.insert(user_id: user.id)
      bogus_user_id = 0

      update_attrs =
        Factory.params(id: Absinthe.Relay.Node.to_global_id(:resume, bogus_user_id, Schema))

      updated_resume_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => updated_resume_str
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: "Resume you are updating does not exist",
                    path: ["updateResume"]
                  }
                ]
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 variables: variables,
                 context: context
               )
    end

    test "update resume fails on attempt to set title to null" do
      user = RegFactory.insert()
      context = context(user)
      resume = Factory.insert(user_id: user.id)

      update_attrs =
        Factory.params(id: Absinthe.Relay.Node.to_global_id(:resume, resume.id, Schema))

      updated_resume_str =
        update_attrs
        |> Factory.stringify()
        |> Map.put("title", nil)

      variables = %{
        "input" => updated_resume_str
      }

      message = Jason.encode!(%{title: "can't be blank"})

      assert {:ok,
              %{
                errors: [
                  %{
                    message: ^message,
                    path: ["updateResume"]
                  }
                ]
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 variables: variables,
                 context: context
               )
    end

    test "delete resume succeeds" do
      user = RegFactory.insert()
      context = context(user)
      %{id: id_} = Factory.insert(user_id: user.id)
      id_ = Integer.to_string(id_)

      variables = %{
        "input" => %{"id" => Absinthe.Relay.Node.to_global_id(:resume, id_, Schema)}
      }

      assert {:ok,
              %{
                data: %{
                  "deleteResume" => %{
                    "resume" => %{
                      "id" => _id,
                      "_id" => ^id_
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.delete(),
                 Schema,
                 variables: variables,
                 context: context
               )
    end

    test "delete resume fails for unknown user" do
      user = RegFactory.insert()
      context = context(user)
      Factory.insert(user_id: user.id)
      bogus_user_id = 0

      variables = %{
        "input" => %{"id" => Absinthe.Relay.Node.to_global_id(:resume, bogus_user_id, Schema)}
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: "Resume you are deleting does not exist",
                    path: ["deleteResume"]
                  }
                ]
              }} =
               Absinthe.run(
                 Query.delete(),
                 Schema,
                 variables: variables,
                 context: context
               )
    end
  end

  describe "query" do
    test "get all resumes for user" do
      user = RegFactory.insert()
      Factory.insert(user_id: user.id)

      variables = %{
        "first" => 1
      }

      assert {:ok,
              %{
                data: %{
                  "resumes" => %{
                    "pageInfo" => %{
                      "hasNextPage" => false
                    },
                    "edges" => [
                      %{
                        "cursor" => _,
                        "node" => %{
                          "id" => _,
                          "_id" => _
                        }
                      }
                    ]
                  }
                }
              }} =
               Absinthe.run(
                 Query.resumes(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  defp context(user), do: %{current_user: user}

  defp assert_assoc(nil, nil) do
    :ok
  end

  defp assert_assoc([], []) do
    :ok
  end

  defp assert_assoc(%{} = a, %{} = b) do
    Enum.each(a, fn
      {_, nil} ->
        :ok

      {k, av} ->
        case b[k] do
          nil ->
            :ok

          bv ->
            if k in [:id, "id"] do
              assert to_string(av) == to_string(bv)
            else
              assert av == bv
            end
        end
    end)
  end

  defp assert_assoc(a, b) when is_list(a) and is_list(b) do
    Enum.zip(a, b)
    |> Enum.each(fn {x, y} -> assert_assoc(x, y) end)
  end
end
