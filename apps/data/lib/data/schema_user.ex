defmodule Data.SchemaUser do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.ResolverUser, as: Resolver

  @desc "User credential"
  object :credential do
    field(:id, non_null(:id))
    field(:source, :string)
    field(:token, :string)
    field(:user, :user)
    field(:inserted_at, non_null(:iso_datetime))
    field(:updated_at, non_null(:iso_datetime))
  end

  @desc "A User"
  node object(:user) do
    field(:_id, non_null(:id))
    field(:jwt, non_null(:string))
    field(:email, non_null(:string))
    field(:name, non_null(:string))
    field(:credential, :credential)

    field(:inserted_at, non_null(:iso_datetime))
    field(:updated_at, non_null(:iso_datetime))
  end

  @desc "Create password recovery success response"
  object :anfordern_passwort_zuruck_setzen do
    field(:email, :string |> non_null)
  end

  @desc "PZS Token Kontrollieren Erfolgeich Nachricht"
  object :pzs_token_kontrollieren_nachricht do
    field(:token, :string |> non_null)
  end

  @desc "Mutations allowed on User object"
  object :user_mutation do
    @doc "Create a user and her credential"
    payload field(:registration) do
      input do
        field(:name, non_null(:string))
        field(:email, non_null(:string))
        field(:source, non_null(:string))
        field(:password, non_null(:string))
        field(:password_confirmation, non_null(:string))
      end

      output do
        field(:user, :user)
      end

      resolve(&Resolver.create/3)
    end

    @doc "Log in a user"
    payload field(:login) do
      input do
        field(:password, non_null(:string))
        field(:email, non_null(:string))
      end

      output do
        field(:user, :user)
      end

      resolve(&Resolver.login/3)
    end

    @doc "Update a user"
    payload field(:update_user) do
      input do
        field(:jwt, non_null(:string))
        field(:name, :string)
        field(:email, :string)
      end

      output do
        field(:user, :user)
      end

      resolve(&Resolver.update/3)
    end

    field :anfordern_passwort_zuruck_setzen, :anfordern_passwort_zuruck_setzen do
      arg(:email, :string |> non_null())
      resolve(&Resolver.anfordern_passwort_zuruck_setzen/3)
    end

    @doc "Reset user password"
    payload field(:veranderung_passwort_zuruck_setzen) do
      input do
        field(:token, non_null(:string))
        field(:password, non_null(:string))
        field(:password_confirmation, non_null(:string))
      end

      output do
        field(:user, :user)
      end

      resolve(&Resolver.veranderung_passwort_zuruck_setzen/3)
    end
  end

  @desc "Queries allowed on User object"
  object :user_query do
    @desc "Refresh a user session"
    field :refresh_user, :user do
      arg(:jwt, non_null(:string))
      resolve(&Resolver.refresh/3)
    end

    @desc "Kontrollieren dass Passwortzurücksetzen Token is nicht falsch"
    field :pzs_token_kontrollieren, :pzs_token_kontrollieren_nachricht do
      arg(:token, non_null(:string))
      resolve(&Resolver.pzs_token_kontrollieren/3)
    end
  end
end
