defmodule Data.TextOnlyQuery do
  @frag_name "TextOnlyFragment"

  @fragment """
    fragment #{@frag_name} on TextOnly {
      id
      text
      ownerId
    }
  """

  def create do
    """
      mutation CreateTextOnlyMutation($input: CreateTextOnlyInput!) {
        createTextOnly(input: $input) {
          ...#{@frag_name}
        }
      }

      #{@fragment}
    """
  end
end
