defmodule Data.SchemaResumeTest do
  use Data.DataCase

  import Absinthe.Relay.Node, only: [to_global_id: 3]

  alias Data.Schema
  alias Data.ResumeFactory, as: Factory
  alias Data.RegistrationFactory, as: RegFactory
  alias Data.QueryResume, as: Query
  alias Data.Resumes
  alias Data.Uploaders.ResumePhoto

  @moduletag :db

  @already_uploaded Resumes.already_uploaded()
  @bogus_id Ecto.ULID.bingenerate()

  describe "mutation resume" do
    test "create resume succeeds" do
      user = RegFactory.insert()

      attrs_str =
        Factory.params()
        |> Factory.stringify()

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
                      "skills" => _
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
    end

    test "update resume succeeds" do
      user = RegFactory.insert()

      attrs = Factory.params(user_id: user.id)

      {:ok, %{title: title, id: id_} = resume} =
        attrs
        |> Factory.parse_photo()
        |> Resumes.create_resume()

      update_attrs =
        Factory.params(
          id: to_global_id(:resume, id_, Schema),
          title: title
        )

      updated_resume_str = Factory.stringify(update_attrs)

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
                      "skills" => _
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.update(),
                 Schema,
                 variables: variables,
                 context: context(user)
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

      update_attrs =
        Factory.params(
          id:
            to_global_id(
              :resume,
              @bogus_id,
              Schema
            )
        )

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
                 context: context(user)
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
      %{id: id_} = Factory.insert(user_id: user.id)

      variables = %{
        "input" => %{"id" => to_global_id(:resume, id_, Schema)}
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
                 context: context(user)
               )
    end

    test "delete resume fails if resume not found" do
      user = RegFactory.insert()
      Factory.insert(user_id: user.id)

      variables = %{
        "input" => %{"id" => to_global_id(:resume, @bogus_id, Schema)}
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
                 context: context(user)
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
      id_str = resume.id

      # since we uploaded a photo before, we pass the flag to signify so
      updated_personal_info =
        Factory.personal_info(1, Sequence.next(""))
        |> Map.merge(%{
          photo: @already_uploaded,
          email: personal_info.email
        })

      update_attrs = %{
        id: to_global_id(:resume, id_str, Schema),
        personal_info: updated_personal_info
      }

      update_attrs_str = Factory.stringify(update_attrs)
      context = context(user)

      variables = %{
        "input" => update_attrs_str
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

      # since we uploaded a photo before, we pass the flag to signify so,
      # but we use the wrong file to get an error response
      bogus_photo = "woops"

      updated_personal_info =
        Factory.personal_info(1, Sequence.next(""))
        |> Map.merge(%{
          photo: bogus_photo,
          email: personal_info.email
        })

      update_attrs = %{
        id: to_global_id(:resume, resume.id, Schema),
        personal_info: updated_personal_info
      }

      update_attrs_str = Factory.stringify(update_attrs)
      context = context(user)

      variables = %{
        "input" => update_attrs_str
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

      assert message =~ bogus_photo
    end

    test "deleting" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          personal_info: Factory.personal_info(1, Sequence.next("")),
          education: nil
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      update_attrs = %{
        personal_info: nil,
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "personalInfo" => nil
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
                    "_id" => ^id,
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

      variables = %{
        "input" => %{
          "title" => title
        }
      }

      assert {:ok,
              %{
                data: %{
                  "getResume" => %{
                    "_id" => ^id,
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
      bogus_gid = to_global_id(:resume, @bogus_id, Schema)

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

  describe "mutation education" do
    test "deleting all" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          education:
            Factory.education(1, Sequence.next("")) ++ Factory.education(1, Sequence.next(""))
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      update_attrs = %{
        education: "nil",
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "education" => []
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
    end

    test "one insert and one update" do
      user = RegFactory.insert()
      education = Factory.education(1, Sequence.next(""))
      attrs = Factory.params(user_id: user.id, education: education)
      %{education: [db_ed]} = resume = Factory.insert(attrs)
      id_str = resume.id

      [ed_for_insert] = Factory.education(1, Sequence.next(""))

      updated_ed = %{
        id: to_string(db_ed.id),
        course: "updated course",
        school: "updated school",
        from_date: "07/2018",
        index: 2
      }

      update_attrs = %{
        education: [
          ed_for_insert,
          updated_ed
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "education" => ed_gql
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

      assert [ed_gql_for_update, ed_gql_for_insert] =
               Enum.sort_by(
                 ed_gql,
                 & &1["id"]
               )

      ed_keys_atom = [:course, :from_date, :school]
      ed_keys_str = ["course", "fromDate", "school"]

      assert Map.take(ed_gql_for_insert, ed_keys_str) ==
               ed_for_insert
               |> Map.take(ed_keys_atom)
               |> Factory.stringify()

      assert Map.take(ed_gql_for_update, ["id", "course", "school", "fromDate"]) ==
               updated_ed
               |> Map.take([:id, :course, :school, :from_date])
               |> Factory.stringify()
    end

    test "one to insert, one to be deleted, one for update" do
      user = RegFactory.insert()
      ed_for_update = Factory.education(1, Sequence.next(""))
      ed_for_delete = Factory.education(1, Sequence.next(""))

      attrs =
        Factory.params(
          user_id: user.id,
          education: ed_for_update ++ ed_for_delete
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      [db_ed_for_update, db_ed_for_delete] =
        Enum.sort_by(
          resume.education,
          & &1.id
        )

      db_ed_for_update_id_str = db_ed_for_update.id

      [ed_for_insert] = Factory.education(1, Sequence.next(""))

      updated_ed = %{
        id: db_ed_for_update_id_str,
        course: "updated course",
        school: "updated school",
        from_date: "07/2018",
        index: 2
      }

      update_attrs = %{
        education: [
          ed_for_insert,
          updated_ed
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "education" => ed_gql
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

      assert [ed_gql_for_update, ed_gql_for_insert] =
               Enum.sort_by(
                 ed_gql,
                 & &1["id"]
               )

      assert ed_gql_for_update["id"] == db_ed_for_update_id_str
      assert ed_gql_for_insert["id"] > db_ed_for_delete.id
    end
  end

  describe "mutation experience" do
    test "deleting all" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          experiences:
            Factory.experiences(1, Sequence.next(""))
            |> Kernel.++(Factory.experiences(1, Sequence.next("")))
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      update_attrs = %{
        experiences: "nil",
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "experiences" => []
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
    end

    test "one insert and one update" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          experiences: Factory.experiences(1, Sequence.next(""))
        )

      %{experiences: [db_exp_for_update]} = resume = Factory.insert(attrs)
      id_str = resume.id

      [exp_for_insert] = Factory.experiences(1, Sequence.next(""))

      updated_exp = %{
        id: to_string(db_exp_for_update.id),
        company_name: "updated company",
        position: "updated position",
        from_date: "07/2018",
        index: 2
      }

      update_attrs = %{
        experiences: [
          exp_for_insert,
          updated_exp
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "experiences" => ed_gql
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

      assert [ed_gql_for_update, ed_gql_for_insert] =
               Enum.sort_by(
                 ed_gql,
                 & &1["id"]
               )

      ed_keys_atom = [
        :company_name,
        :from_date,
        :position
      ]

      ed_keys_str = [
        "companyName",
        "fromDate",
        "position"
      ]

      assert Map.take(ed_gql_for_insert, ed_keys_str) ==
               exp_for_insert
               |> Map.take(ed_keys_atom)
               |> Factory.stringify()

      assert ed_gql_for_update
             |> Map.take(["id", "companyName", "position", "fromDate"]) ==
               updated_exp
               |> Map.take([:id, :company_name, :position, :from_date])
               |> Factory.stringify()
    end

    test "one insert, one delete, one update" do
      user = RegFactory.insert()
      exp_for_update = Factory.experiences(1, Sequence.next(""))
      exp_for_delete = Factory.experiences(1, Sequence.next(""))

      attrs =
        Factory.params(
          user_id: user.id,
          experiences: exp_for_update ++ exp_for_delete
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      [db_exp_for_update, db_exp_for_delete] =
        Enum.sort_by(
          resume.experiences,
          & &1.id
        )

      db_exp_for_update_id_str = db_exp_for_update.id

      [exp_for_insert] = Factory.experiences(1, Sequence.next(""))

      updated_exp = %{
        id: db_exp_for_update_id_str,
        company_name: "updated company",
        position: "updated position",
        from_date: "07/2018",
        index: 2
      }

      update_attrs = %{
        experiences: [
          exp_for_insert,
          updated_exp
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "experiences" => experiences_graphql
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

      assert [exp_gql_for_update, exp_gql_for_insert] =
               Enum.sort_by(
                 experiences_graphql,
                 & &1["id"]
               )

      assert exp_gql_for_update["id"] == db_exp_for_update_id_str
      assert exp_gql_for_insert["id"] > db_exp_for_delete.id
    end
  end

  describe "mutation skills" do
    test "deleting all" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          skills: Factory.skills(1, Sequence.next("")) ++ Factory.skills(1, Sequence.next("")),
          education: nil
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      update_attrs = %{
        skills: "nil",
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "skills" => []
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
    end

    test "one insert and one update" do
      user = RegFactory.insert()

      attrs =
        Factory.params(
          user_id: user.id,
          skills: Factory.skills(1, Sequence.next(""))
        )

      %{skills: [db_skill_for_update]} = resume = Factory.insert(attrs)
      id_str = resume.id

      [skill_for_insert] = Factory.skills(1, Sequence.next(""))

      updated_skill = %{
        id: to_string(db_skill_for_update.id),
        description: "updated description",
        index: 2
      }

      update_attrs = %{
        skills: [
          skill_for_insert,
          updated_skill
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "skills" => skills_graphql
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

      assert [skills_gql_for_update, skill_gql_inserted] =
               Enum.sort_by(
                 skills_graphql,
                 & &1["id"]
               )

      assert skill_gql_inserted["description"] == skill_for_insert[:description]

      assert skills_gql_for_update
             |> Map.take(["id", "description"]) ==
               updated_skill
               |> Map.take([:id, :description])
               |> Factory.stringify()
    end

    test "one insert, one delete, one update" do
      user = RegFactory.insert()
      skill_for_update = Factory.skills(1, Sequence.next(""))
      skill_for_delete = Factory.skills(1, Sequence.next(""))

      attrs =
        Factory.params(
          user_id: user.id,
          skills: skill_for_update ++ skill_for_delete
        )

      resume = Factory.insert(attrs)
      id_str = resume.id

      [db_skill_for_update, db_skill_for_delete] =
        Enum.sort_by(
          resume.skills,
          & &1.id
        )

      db_skill_for_update_id_str = db_skill_for_update.id

      [skill_for_insert] = Factory.skills(1, Sequence.next(""))

      updated_skill = %{
        id: db_skill_for_update_id_str,
        description: "updated description",
        index: 2
      }

      update_attrs = %{
        skills: [
          skill_for_insert,
          updated_skill
        ],
        id: to_global_id(:resume, id_str, Schema)
      }

      update_attrs_str = Factory.stringify(update_attrs)

      variables = %{
        "input" => update_attrs_str
      }

      context = context(user)

      assert {:ok,
              %{
                data: %{
                  "updateResume" => %{
                    "resume" => %{
                      "_id" => ^id_str,
                      "skills" => experiences_graphql
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

      assert [exp_gql_for_update, exp_gql_for_insert] =
               Enum.sort_by(
                 experiences_graphql,
                 & &1["id"]
               )

      assert exp_gql_for_update["id"] == db_skill_for_update_id_str
      assert exp_gql_for_insert["id"] > db_skill_for_delete.id
    end
  end

  describe "clone resume" do
    test "clone with same title succeeds" do
      user = RegFactory.insert()
      resume = Factory.insert(user_id: user.id)
      id = resume.id

      variables = %{
        "input" => %{
          "id" => to_global_id(:resume, id, Schema)
        }
      }

      assert {:ok,
              %{
                data: %{
                  "cloneResume" => %{
                    "resume" => %{
                      "id" => _,
                      "_id" => new_id,
                      "title" => new_resume_title,
                      "personalInfo" => _personal_info
                    }
                  }
                }
              }} =
               Absinthe.run(Query.clone(), Schema,
                 context: context(user),
                 variables: variables
               )

      assert id < new_id
      assert new_resume_title =~ resume.title
    end

    test "clone with different title succeeds" do
      user = RegFactory.insert()
      resume = Factory.insert(user_id: user.id)
      new_title = Faker.String.base64()

      variables = %{
        "input" => %{
          "id" => to_global_id(:resume, resume.id, Schema),
          "title" => new_title
        }
      }

      assert {:ok,
              %{
                data: %{
                  "cloneResume" => %{
                    "resume" => %{
                      "id" => _,
                      "title" => ^new_title
                    }
                  }
                }
              }} =
               Absinthe.run(Query.clone(), Schema,
                 context: context(user),
                 variables: variables
               )
    end

    test "clone fails if resume does not exist" do
      user = RegFactory.insert()

      variables = %{
        "input" => %{
          "id" => to_global_id(:resume, @bogus_id, Schema)
        }
      }

      assert {:ok,
              %{
                errors: [
                  %{
                    message: "Resume you are trying to clone does not exist"
                  }
                ]
              }} =
               Absinthe.run(Query.clone(), Schema,
                 context: context(user),
                 variables: variables
               )
    end

    test "clone mit Bild" do
      user = RegFactory.insert()

      personal_info =
        Factory.personal_info(1, Sequence.next(""))
        |> Map.put(:photo, Factory.photo_plug())

      resume = Factory.insert(user_id: user.id, personal_info: personal_info)

      variables = %{
        "input" => %{
          "id" => to_global_id(:resume, resume.id, Schema)
        }
      }

      assert {:ok,
              %{
                data: %{
                  "cloneResume" => %{
                    "resume" => %{
                      "id" => _,
                      "_id" => _,
                      "personalInfo" => %{
                        "photo" => photo
                      }
                    }
                  }
                }
              }} =
               Absinthe.run(Query.clone(), Schema,
                 context: context(user),
                 variables: variables
               )

      assert photo =~ resume.personal_info.photo.file_name
    end
  end

  defp context(user), do: %{current_user: user}
end
