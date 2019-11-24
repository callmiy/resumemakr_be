defmodule Data.QueryUser do
  @frag_name "UserAllFieldsFragment"

  def all_fields_fragment do
    fragment = """
      fragment #{@frag_name} on User {
        id
        name
        email
        jwt
        insertedAt
        updatedAt
      }
    """

    {@frag_name, fragment}
  end

  @doc "update"
  def update do
    {user_frag_name, user_frag} = all_fields_fragment()

    query = """
        updateUser(input: $input) {
          user {
            ...#{user_frag_name}
          }
        }
    """

    %{
      query: query,
      fragments: ~s( #{user_frag} ),
      parameters: "$input: UpdateUserInput!"
    }
  end

  @doc "refresh"
  def refresh do
    {user_frag_name, user_frag} = all_fields_fragment()

    query = """
        refreshUser(jwt: $jwt) {
          ...#{user_frag_name}
        }
    """

    %{
      query: query,
      fragments: ~s( #{user_frag} ),
      parameters: "$jwt: String!"
    }
  end

  @doc "Login"
  def login do
    {_, user_frag} = all_fields_fragment()

    query = """
        login(input: $input) {
          user {
            ...#{@frag_name}
          }
        }
    """

    %{
      query: query,
      fragments: ~s(  #{user_frag} ),
      parameters: "$input: LoginInput!"
    }
  end

  @doc "password_recovery"
  def password_recovery(email) do
    """
      mutation RequestPasswordResetToken{
        requestPasswordResetToken(email: "#{email}") {
          email
        }
      }
    """
  end

  @doc "reset_password"
  def reset_password do
    {_, user_frag} = all_fields_fragment()

    """
      mutation ResetPassword($input: ResetPasswordInput!) {
        resetPassword(input: $input) {
          user {
            ...#{@frag_name}
          }
        }
      }

      #{user_frag}
    """
  end

  def validate_password_reset_token(token) do
    """
      query ConfirmPasswordResetToken {
        confirmPasswordResetToken(token: "#{token}") {
          token
        }
      }
    """
  end

  def reset_password_simple do
    {_, user_frag} = all_fields_fragment()

    """
      mutation ResetPasswordSimple($input: ResetPasswordSimpleInput!) {
        resetPasswordSimple(input: $input) {
          user {
            ...#{@frag_name}
          }
        }
      }

      #{user_frag}
    """
  end
end
