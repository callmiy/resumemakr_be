defmodule Data.SchemaResumeTest do
  use Data.DataCase

  import Absinthe.Relay.Node, only: [to_global_id: 3]

  alias Data.Schema
  alias Data.FactoryResume, as: Factory
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryResume, as: Query
  alias Data.Resumes

  @moduletag :db

  @dog_pattern ~r/dog\.jpeg/

  describe "mutation" do
    test "create resume succeeds" do
      user = RegFactory.insert()

      attrs_str =
        Factory.params()
        |> Factory.stringify()

      {context, attrs_str} = context(user, attrs_str)

      variables = %{
        "input" => attrs_str
      }

      description = attrs_str["description"]
      title = attrs_str["title"]

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
                      "languages" => languages,
                      "hobbies" => _hobbies
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.create_resume(),
                 Schema,
                 variables: variables,
                 context: context
               )

      assert_assoc(attrs_str["experiences"] || [], experiences)
      assert_assoc(personal_info, attrs_str["personalInfo"])
      assert_assoc(education, attrs_str["education"] || [])
      assert_assoc(languages, attrs_str["languages"] || [])
      assert_assoc(skills, attrs_str["skills"] || [])
      assert_assoc(additional_skills, attrs_str["additionalSkills"] || [])
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
      attrs = Factory.params(user_id: user.id)

      {:ok, %{title: title, id: id_} = resume} = Resumes.create_resume(attrs)
      id_ = Integer.to_string(id_)

      update_attrs =
        Factory.params(
          id: to_global_id(:resume, id_, Schema),
          title: title
        )

      updated_resume_str = Factory.stringify(update_attrs)
      {context, updated_resume_str} = context(user, updated_resume_str)

      variables = %{
        "input" => updated_resume_str
      }

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "id" => _id,
                      "_id" => ^id_,
                      "title" => ^title,
                      "description" => new_description,
                      "personalInfo" => personal_info,
                      "experiences" => experiences,
                      "education" => education,
                      "skills" => skills,
                      "additionalSkills" => additional_skills,
                      "languages" => languages,
                      "hobbies" => _hobbies
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

      case Map.has_key?(updated_resume_str, "description") do
        true ->
          assert new_description == updated_resume_str["description"]

        _ ->
          assert new_description == resume.description
      end

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
      Factory.insert(user_id: user.id)
      bogus_user_id = 0

      update_attrs =
        Factory.params(
          id:
            to_global_id(
              :resume,
              bogus_user_id,
              Schema
            )
        )

      updated_resume_str = Factory.stringify(update_attrs)
      {context, updated_resume_str} = context(user, updated_resume_str)

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
      resume = Factory.insert(user_id: user.id)

      update_attrs =
        Factory.params(id: Absinthe.Relay.Node.to_global_id(:resume, resume.id, Schema))

      updated_resume_str =
        update_attrs
        |> Factory.stringify()
        |> Map.put("title", nil)

      {context, updated_resume_str} = context(user, updated_resume_str)

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
        "input" => %{"id" => to_global_id(:resume, bogus_user_id, Schema)}
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
                  "listResumes" => %{
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
                 Query.list_resumes(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end

    test "get a resume for user succeeds for valid user id and title" do
      user = RegFactory.insert()
      %{id: id, title: title} = Factory.insert(user_id: user.id)
      sid = Integer.to_string(id)
      gid = to_global_id(:resume, id, Schema)

      variables = %{
        "input" => %{
          "title" => title,
          "id" => gid
        }
      }

      assert {:ok,
              %{
                data: %{
                  "getResume" => %{
                    "id" => ^gid,
                    "_id" => ^sid,
                    "title" => ^title
                  }
                }
              }} =
               Absinthe.run(
                 Query.get_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end

    test "get a resume for user succeeds for valid title" do
      user = RegFactory.insert()
      %{id: id, title: title} = Factory.insert(user_id: user.id)
      sid = Integer.to_string(id)

      variables = %{
        "input" => %{
          "title" => title
        }
      }

      assert {:ok,
              %{
                data: %{
                  "getResume" => %{
                    "_id" => ^sid,
                    "title" => ^title
                  }
                }
              }} =
               Absinthe.run(
                 Query.get_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end

    test "get a resume for user fails for invalid query argument(s)" do
      user = RegFactory.insert()
      %{title: title} = Factory.insert(user_id: user.id)
      bogus_gid = to_global_id(:resume, "0", Schema)

      input =
        Enum.random([
          %{"title" => title <> "0"},
          %{"id" => bogus_gid}
        ])

      variables = %{
        "input" => input
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: "resume not found"
                  }
                ]
              }} =
               Absinthe.run(
                 Query.get_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end

    test "get a resume for user fails for empty argument(s)" do
      user = RegFactory.insert()

      variables = %{
        "input" => %{}
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: "invalid query arguments"
                  }
                ]
              }} =
               Absinthe.run(
                 Query.get_resume(),
                 Schema,
                 variables: variables,
                 context: context(user)
               )
    end
  end

  defp context(user), do: %{current_user: user}

  defp context(user, %{"personalInfo" => nil} = attrs),
    do: {context(user), attrs}

  defp context(user, %{"personalInfo" => %{"photo" => nil}} = attrs),
    do: {context(user), attrs}

  defp context(user, %{"personalInfo" => %{"photo" => photo_upload_plug}} = attrs) do
    {
      update_in(
        context(user)[:__absinthe_plug__],
        &Map.put(&1 || %{}, :uploads, %{"photo" => photo_upload_plug})
      ),
      update_in(attrs["personalInfo"]["photo"], fn _ -> "photo" end)
    }
  end

  defp context(user, attrs), do: {context(user), attrs}

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
            cond do
              k == "id" ->
                assert to_string(av) == to_string(bv)

              k == "photo" ->
                assert_photo(av, bv)

              true ->
                assert av == bv
            end
        end
    end)
  end

  defp assert_assoc(a, b) when is_list(a) and is_list(b) do
    Enum.zip(a, b)
    |> Enum.each(fn {x, y} -> assert_assoc(x, y) end)
  end

  defp assert_photo("photo", v) when is_binary(v) do
    assert Regex.match?(@dog_pattern, v)
  end

  defp assert_photo(v, "photo") when is_binary(v) do
    assert Regex.match?(@dog_pattern, v)
  end

  defp assert_photo(%{filename: filename}, "photo") do
    assert Regex.match?(@dog_pattern, filename)
  end

  defp assert_photo("photo", %{filename: filename}) do
    assert Regex.match?(@dog_pattern, filename)
  end

  defp assert_photo(%{filename: filename}, v) do
    assert Regex.match?(@dog_pattern, filename)
    assert Regex.match?(@dog_pattern, v)
  end

  defp assert_photo(v, %{filename: filename}) do
    assert Regex.match?(@dog_pattern, filename)
    assert Regex.match?(@dog_pattern, v)
  end

  defp assert_photo(%{file_name: file_name}, v) do
    assert Regex.match?(@dog_pattern, file_name)
    assert Regex.match?(@dog_pattern, v)
  end

  defp assert_photo(v, %{file_name: file_name}) do
    assert Regex.match?(@dog_pattern, file_name)
    assert Regex.match?(@dog_pattern, v)
  end
end
