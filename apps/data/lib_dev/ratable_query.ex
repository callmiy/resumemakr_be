defmodule Data.RatableQuery do
  @fragment_name "RatedFragment"

  @all_fields_fragment """
    fragment #{@fragment_name} on Ratable {
      id
      description
      level
      resumeId
    }
  """

  def create do
    """
      mutation CreateRatable($input: CreateRatableInput!) {
        createRatable(input: $input) {
          ...#{@fragment_name}
        }
      }

      #{@all_fields_fragment}
    """
  end
end
