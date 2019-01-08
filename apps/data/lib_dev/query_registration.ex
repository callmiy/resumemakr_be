defmodule Data.QueryRegistration do
  alias Data.QueryCredential
  alias Data.QueryUser

  @doc "Register"
  def register do
    {user_frag_name, user_frag} = QueryUser.all_fields_fragment()

    {
      credential_frag_name,
      credential_frag
    } = QueryCredential.all_fields_fragment()

    query = """
        registration(input: $input) {
          user {
            ...#{user_frag_name}

            credential {
              ...#{credential_frag_name}
            }
          }
        }
    """

    %{
      query: query,
      fragments: ~s( #{credential_frag} #{user_frag} ),
      parameters: "$input: RegistrationInput!"
    }
  end
end
