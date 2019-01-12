defmodule Data.SchemaResumeTest do
  use Data.DataCase

  import Absinthe.Relay.Node, only: [to_global_id: 3]

  alias Data.Schema
  alias Data.FactoryResume, as: Factory
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryResume, as: Query
  alias Data.Resumes
  alias Data.Uploaders.ResumePhoto

  @moduletag :db

  @already_uploaded Resumes.already_uploaded()

  describe "mutation resume" do
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
                      "personalInfo" => _,
                      "experiences" => _,
                      "education" => _,
                      "skills" => _,
                      "additionalSkills" => _,
                      "languages" => _,
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
                      "personalInfo" => _,
                      "experiences" => _,
                      "education" => _,
                      "skills" => _,
                      "additionalSkills" => _,
                      "languages" => _,
                      "hobbies" => _
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
      attrs = Factory.params(user_id: user.id)
      resume = Factory.insert(attrs)

      update_attrs =
        Factory.params(
          id:
            to_global_id(
              :resume,
              resume.id,
              Schema
            )
        )

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

  describe "mutation personal info" do
    test "update resume with an existing photo succeeds with correct flag" do
      user = RegFactory.insert()
      seq = Sequence.next("")

      personal_info =
        Factory.personal_info(1, seq)
        |> Map.put(:photo, Factory.photo_plug())

      resume = Factory.insert(user_id: user.id, personal_info: personal_info)
      id_str = Integer.to_string(resume.id)

      # since we uploaded a photo before, we pass the flag to signify so
      updated_personal_info =
        Factory.personal_info(1, Sequence.next(""))
        |> Map.merge(%{
          photo: @already_uploaded,
          email: personal_info.email
        })

      updated_attrs = %{
        id: to_global_id(:resume, id_str, Schema),
        personal_info: updated_personal_info
      }

      updated_attrs_str = Factory.stringify(updated_attrs)
      context = context(user)

      variables = %{
        "input" => updated_attrs_str
      }

      photo =
        ResumePhoto.url({
          resume.personal_info.photo.file_name,
          resume.personal_info
        })

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "personalInfo" => %{
                        "photo" => ^photo
                      }
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 context: context,
                 variables: variables
               )
    end

    test "update resume with an existing photo fails with incorrect flag" do
      user = RegFactory.insert()
      seq = Sequence.next("")

      personal_info =
        Factory.personal_info(1, seq)
        |> Map.put(:photo, Factory.photo_plug())

      resume = Factory.insert(user_id: user.id, personal_info: personal_info)
      id_str = Integer.to_string(resume.id)

      # since we uploaded a photo before, we pass the flag to signify so,
      # but we use the wrong file to get an error response
      updated_personal_info =
        Factory.personal_info(1, Sequence.next(""))
        |> Map.merge(%{
          photo: "woops",
          email: personal_info.email
        })

      updated_attrs = %{
        id: to_global_id(:resume, id_str, Schema),
        personal_info: updated_personal_info
      }

      updated_attrs_str = Factory.stringify(updated_attrs)
      context = context(user)

      variables = %{
        "input" => updated_attrs_str
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: message
                  }
                ]
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 context: context,
                 variables: variables
               )

      assert message =~ "woops"
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

  defp context(user, %{"personalInfo" => %{"photo" => %{} = plug}} = attrs) do
    {
      update_in(
        context(user)[:__absinthe_plug__],
        &Map.put(&1 || %{}, :uploads, %{"photo" => plug})
      ),
      update_in(attrs["personalInfo"]["photo"], fn _ -> "photo" end)
    }
  end

  defp context(user, attrs), do: {context(user), attrs}
end
