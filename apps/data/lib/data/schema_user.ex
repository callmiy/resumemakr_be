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
  object :pwd_recovery do
    field :email, :string |> non_null
  end

  @desc "Mutations allowed on User object"
  object :user_mutation do
    @doc "Create a user and her credential"
    payload field :registration do
      input do
        field :name, non_null(:string)
        field :email, non_null(:string)
        field :source, non_null(:string)
        field :password, non_null(:string)
        field :password_confirmation, non_null(:string)
      end

      output do
        field :user, :user
      end

      resolve(&Resolver.create/3)
    end

    @doc "Log in a user"
    payload field :login do
      input do
        field :password, non_null(:string)
        field :email, non_null(:string)
      end

      output do
        field :user, :user
      end

      resolve(&Resolver.login/3)
    end

    @doc "Update a user"
    payload field :update_user do
      input do
        field :jwt, non_null(:string)
        field :name, :string
        field :email, :string
      end

      output do
        field :user, :user
      end

      resolve(&Resolver.update/3)
    end

    field :recover_pwd, :pwd_recovery do
      arg(:email, :string |> non_null())
      resolve(&Resolver.create_pwd_recovery/3)
    end
  end

  @desc "Queries allowed on User object"
  object :user_query do
    @desc "Refresh a user session"
    field :refresh_user, :user do
      arg(:jwt, non_null(:string))
      resolve(&Resolver.refresh/3)
    end
  end
end
