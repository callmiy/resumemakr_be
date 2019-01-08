defmodule Data.SchemaUserTest do
  use Data.DataCase

  alias Data.Schema
  alias Data.QueryRegistration, as: RegQuery
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryUser, as: Query
  alias Data.FactoryUser, as: Factory
  alias Data.Guardian

  @moduletag :db

  describe "mutation" do
    # @tag :skip
    test "registers user succeeds" do
      %{
        "name" => name,
        "email" => email
      } =
        attrs =
        RegFactory.params()
        |> RegFactory.stringify()

      queryMap = RegQuery.register()

      query = """
        mutation RegisterUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      assert {:ok,
              %{
                data: %{
                  "registration" => %{
                    "user" => %{
                      "id" => _,
                      "name" => ^name,
                      "email" => ^email,
                      "jwt" => _jwt,
                      "credential" => %{
                        "id" => _
                      }
                    }
                  }
                }
              }} =
               Absinthe.run(query, Schema,
                 variables: %{
                   "input" => attrs
                 }
               )
    end

    # @tag :skip
    test "registers user fails for none unique email" do
      attrs = RegFactory.params()

      RegFactory.insert(attrs)
      queryMap = RegQuery.register()

      query = """
        mutation RegisterUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      variables = %{
        "input" => RegFactory.stringify(attrs)
      }

      error =
        %{
          errors: %{
            email: "has already been taken"
          },
          name: "user"
        }
        |> Jason.encode!()

      assert {:ok,
              %{
                errors: [
                  %{
                    message: ^error,
                    path: ["registration"]
                  }
                ]
              }} = Absinthe.run(query, Schema, variables: variables)
    end

    # @tag :skip
    test "update user succeeds" do
      user = RegFactory.insert()
      {:ok, jwt, _claim} = Guardian.encode_and_sign(user)

      attrs =
        Factory.params(jwt: jwt)
        |> RegFactory.stringify()

      queryMap = Query.update()

      query = """
        mutation updateUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      variables = %{
        "input" => attrs
      }

      assert {:ok,
              %{
                data: %{
                  "updateUser" => %{
                    "user" => %{
                      "id" => _,
                      "name" => name,
                      "email" => email,
                      "jwt" => _jwt
                    }
                  }
                }
              }} =
               Absinthe.run(
                 query,
                 Schema,
                 variables: variables,
                 context: context(user)
               )

      refute user.name == name
      refute user.email == email
    end

    # @tag :skip
    test "login succeeds" do
      %{email: email, password: password} = params = RegFactory.params()
      RegFactory.insert(params)
      queryMap = Query.login()

      query = """
        mutation LoginUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      variables = %{
        "input" => %{
          "email" => email,
          "password" => password
        }
      }

      assert {:ok,
              %{
                data: %{
                  "login" => %{
                    "user" => %{
                      "id" => _,
                      "name" => name,
                      "email" => ^email,
                      "jwt" => _jwt
                    }
                  }
                }
              }} = Absinthe.run(query, Schema, variables: variables)
    end

    # @tag :skip
    test "login fails" do
      %{email: email, password: password} = params = RegFactory.params()
      RegFactory.insert(params)

      queryMap = Query.login()

      query = """
        mutation LoginUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      password = password <> "q"

      assert {:ok,
              %{
                errors: [%{message: "{\"error\":\"Invalid email/password\"}"}]
              }} =
               Absinthe.run(query, Schema,
                 variables: %{
                   "input" => %{
                     "email" => email,
                     "password" => password
                   }
                 }
               )
    end
  end

  describe "query" do
    test "refreshes user succeeds with ok jwt" do
      user = RegFactory.insert()
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      queryMap = Query.refresh()

      query = """
        query RefreshUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      assert {:ok,
              %{
                data: %{
                  "refreshUser" => %{"id" => _, "jwt" => new_jwt}
                }
              }} = Absinthe.run(query, Schema, variables: %{"jwt" => jwt})

      refute jwt == new_jwt
    end

    test "refreshes user fails for tampered with jwt" do
      user = RegFactory.insert()
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      queryMap = Query.refresh()

      query = """
        query RefreshUser(#{queryMap.parameters}) {
          #{queryMap.query}
        }

        #{queryMap.fragments}
      """

      assert {:ok,
              %{
                data: %{"refreshUser" => nil},
                errors: [
                  %{
                    message: "{\"error\":\"invalid_token\"}",
                    path: ["refreshUser"]
                  }
                ]
              }} = Absinthe.run(query, Schema, variables: %{"jwt" => jwt <> "9"})
    end
  end

  defp context(user) do
    %{current_user: user}
  end
end
