defmodule Data.SchemaUserTest do
  use Data.DataCase

  import Absinthe.Relay.Node, only: [to_global_id: 3]
  import ExUnit.CaptureLog

  alias Data.Schema
  alias Data.QueryRegistration, as: RegQuery
  alias Data.FactoryRegistration, as: RegFactory
  alias Data.QueryUser, as: Query
  alias Data.FactoryUser, as: Factory
  alias Data.Guardian
  alias Data.Accounts
  alias Data.Accounts.Credential
  alias Data.Resolver

  @moduletag capture_log: true

  @get_password_reset_token_expiry_in_hours Accounts.get_password_reset_token_expiry_in_hours()

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

      query_map = RegQuery.register()

      query = """
        mutation RegisterUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
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
      query_map = RegQuery.register()

      query = """
        mutation RegisterUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
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

      query_map = Query.update()

      query = """
        mutation updateUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
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
      query_map = Query.login()

      query = """
        mutation LoginUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
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

      query_map = Query.login()

      query = """
        mutation LoginUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
      """

      password = password <> "q"

      assert {:ok,
              %{
                errors: [%{message: "Invalid email/password"}]
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

    test "login rescues errors" do
      %{
        email: email,
        password: password
      } = params = RegFactory.params()

      %{
        credential: credential
      } = RegFactory.insert(params)

      credential
      |> Credential.changeset(%{token: "1"})
      |> Data.Repo.update()

      log_message =
        capture_log(fn ->
          assert {:error, error} =
                   Data.Accounts.authenticate(%{
                     email: email,
                     password: password
                   })

          assert is_binary(error)
        end)

      assert log_message =~ "STACK"
    end
  end

  describe "query" do
    test "refreshes user succeeds with ok jwt" do
      user = RegFactory.insert()
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      query_map = Query.refresh()

      query = """
        query RefreshUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
      """

      assert {:ok,
              %{
                data: %{
                  "refreshUser" => %{"id" => _, "jwt" => new_jwt}
                }
              }} = Absinthe.run(query, Schema, variables: %{"jwt" => jwt})

      refute jwt == new_jwt
    end

    test "refresh user fails for tampered with jwt" do
      user = RegFactory.insert()
      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      query_map = Query.refresh()

      query = """
        query RefreshUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
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

    test "aktualisieren benutzer fehler für bogus-Token" do
      query_map = Query.refresh()

      query = """
        query RefreshUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
      """

      token = "bogus-token"

      assert {:ok,
              %{
                data: %{"refreshUser" => nil},
                errors: [
                  %{
                    message: "{\"error\":\"invalid_token\"}",
                    path: ["refreshUser"]
                  }
                ]
              }} = Absinthe.run(query, Schema, variables: %{"jwt" => token})
    end
  end

  describe "password recovery" do
    # @tag :skip
    test "anfordern passwort recovery succeeds if user found with email" do
      %{email: email} = RegFactory.insert()

      assert {:ok,
              %{
                data: %{
                  "requestPasswordResetToken" => %{
                    "email" => ^email
                  }
                }
              }} = Absinthe.run(Query.password_recovery(email), Schema)
    end

    test "anfordern password recovery fails: user not found" do
      bogus_email = "me@bogus.com"

      error = "Unknown user email: #{bogus_email}"

      assert {:ok,
              %{
                errors: [
                  %{
                    message: ^error
                  }
                ]
              }} = Absinthe.run(Query.password_recovery(bogus_email), Schema)
    end

    test "Password reset succeeds" do
      alte_passwort = "alte passwort"
      neue_passwort = "neue passwort"

      user =
        RegFactory.insert(
          password: alte_passwort,
          password_confirmation: alte_passwort
        )

      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      {:ok, _anmelden_info} =
        Accounts.update_credential(user.credential, %{
          recovery_token: jwt,
          recovery_token_expires: Timex.now() |> Timex.shift(hours: @get_password_reset_token_expiry_in_hours)
        })

      id = to_global_id(:user, user.id, Schema)

      variables = %{
        "input" => %{
          "token" => jwt,
          "password" => neue_passwort,
          "passwordConfirmation" => neue_passwort
        }
      }

      assert {:ok,
              %{
                data: %{
                  "resetPassword" => %{
                    "user" => %{
                      "id" => ^id,
                      "jwt" => _
                    }
                  }
                }
              }} =
               Absinthe.run(
                 Query.reset_password(),
                 Schema,
                 variables: variables
               )

      query_map = Query.login()

      query = """
        mutation LoginUser(#{query_map.parameters}) {
          #{query_map.query}
        }

        #{query_map.fragments}
      """

      incorrect_login_variables = %{
        "input" => %{
          "email" => user.email,
          "password" => alte_passwort
        }
      }

      assert {:ok,
              %{
                errors: [%{message: _}]
              }} =
               Absinthe.run(
                 query,
                 Schema,
                 variables: incorrect_login_variables
               )

      correct_login_variables = %{
        "input" => %{
          "email" => user.email,
          "password" => neue_passwort
        }
      }

      assert {:ok,
              %{
                data: %{
                  "login" => %{
                    "user" => %{
                      "id" => ^id,
                      "jwt" => _
                    }
                  }
                }
              }} =
               Absinthe.run(
                 query,
                 Schema,
                 variables: correct_login_variables
               )
    end

    test "Password reset fails: token already used." do
      alte_passwort = "alte passwort"
      neue_passwort = "neue passwort"

      user =
        RegFactory.insert(
          password: alte_passwort,
          password_confirmation: alte_passwort
        )

      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      {:ok, %Credential{} = _anmelden_info} =
        Accounts.update_credential(user.credential, %{
          recovery_token: jwt,
          recovery_token_expires: Timex.now() |> Timex.shift(hours: @get_password_reset_token_expiry_in_hours)
        })

      {:ok, %Credential{} = _anmelden_info} =
        Accounts.bekommt_anmelden_info_pzs(jwt, %{
          password: neue_passwort,
          password_confirmation: neue_passwort
        })

      variables = %{
        "input" => %{
          "token" => jwt,
          "password" => neue_passwort,
          "passwordConfirmation" => neue_passwort
        }
      }

      nachricht = Resolver.nicht_berechtigung()

      assert {:ok,
              %{
                errors: [%{message: ^nachricht}]
              }} =
               Absinthe.run(
                 Query.reset_password(),
                 Schema,
                 variables: variables
               )
    end

    test "Password reset fails: token expired" do
      alte_passwort = "alte passwort"
      neue_passwort = "neue passwort"

      user =
        RegFactory.insert(
          password: alte_passwort,
          password_confirmation: alte_passwort
        )

      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)

      {:ok, %Credential{} = _anmelden_info} =
        Accounts.update_credential(user.credential, %{
          recovery_token: jwt,
          recovery_token_expires: Timex.now() |> Timex.shift(minutes: -30)
        })

      variables = %{
        "input" => %{
          "token" => jwt,
          "password" => neue_passwort,
          "passwordConfirmation" => neue_passwort
        }
      }

      nachricht = Resolver.nicht_berechtigung()

      assert {:ok,
              %{
                errors: [%{message: ^nachricht}]
              }} =
               Absinthe.run(
                 Query.reset_password(),
                 Schema,
                 variables: variables
               )
    end

    test "Password reset fails: invalid token" do
      alte_passwort = "alte passwort"
      neue_passwort = "neue passwort"

      user =
        RegFactory.insert(
          password: alte_passwort,
          password_confirmation: alte_passwort
        )

      {:ok, jwt, _claims} = Guardian.encode_and_sign(user)
      falschToken = jwt <> " ist falsch"

      {:ok, %Credential{} = _anmelden_info} =
        Accounts.update_credential(user.credential, %{
          recovery_token: jwt,
          recovery_token_expires: Timex.now() |> Timex.shift(minutes: -30)
        })

      variables = %{
        "input" => %{
          "token" => falschToken,
          "password" => neue_passwort,
          "passwordConfirmation" => neue_passwort
        }
      }

      nachricht = Resolver.nicht_berechtigung()

      assert {:ok,
              %{
                errors: [%{message: ^nachricht}]
              }} =
               Absinthe.run(
                 Query.reset_password(),
                 Schema,
                 variables: variables
               )
    end

    test "Password token confirmation succeeds" do
      user = RegFactory.insert()
      {:ok, jwt, _claim} = Data.Guardian.encode_and_sign(user)
      {:ok, _} = Accounts.get_password_token(user.credential, jwt)

      assert {:ok,
              %{
                data: %{
                  "confirmPasswordResetToken" => %{
                    "token" => ^jwt
                  }
                }
              }} =
               Absinthe.run(
                 Query.validate_password_reset_token(jwt),
                 Schema
               )
    end

    test "Password reset token confirmation fails: token expires" do
      user = RegFactory.insert()
      {:ok, jwt, _claim} = Data.Guardian.encode_and_sign(user)

      {:ok, %Credential{} = _anmelden_info} =
        Accounts.update_credential(user.credential, %{
          recovery_token: jwt,
          recovery_token_expires: Timex.now() |> Timex.shift(minutes: -30)
        })

      nachricht = Resolver.nicht_berechtigung()

      assert {:ok,
              %{
                errors: [
                  %{
                    message: ^nachricht
                  }
                ]
              }} =
               Absinthe.run(
                 Query.validate_password_reset_token(jwt),
                 Schema
               )
    end

    test "Password reset token confirmation fails if token not found" do
      falsch_token = "wrong token"
      nachricht = Resolver.nicht_berechtigung()

      assert {:ok,
              %{
                errors: [
                  %{
                    message: ^nachricht
                  }
                ]
              }} =
               Absinthe.run(
                 Query.validate_password_reset_token(falsch_token),
                 Schema
               )
    end
  end

  defp context(user) do
    %{current_user: user}
  end
end
