defmodule Web.QueryRegistration do
  alias Web.QueryCredential
  alias Web.QueryUser

  @doc "Register"
  def register do
    {user_frag_name, user_frag} = QueryUser.all_fields_fragment()

    {
      credential_frag_name, credential_frag
      } = QueryCredential.all_fields_fragment()

    query = """
        registration(registration: $registration) {
          ...#{user_frag_name}

          credential {
            ...#{credential_frag_name}
          }
        }
    """

    %{
      query: query,
      fragments: ~s( #{credential_frag} #{user_frag} ),
      parameters: "$registration: Registration!"
    }
  end
end
