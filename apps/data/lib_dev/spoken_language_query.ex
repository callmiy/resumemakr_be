defmodule Data.SpokenLanguageQuery do
  @fragment_name "SpokenLanguageFragment"

  @all_fields_fragment """
    fragment #{@fragment_name} on SpokenLanguage {
      id
      description
      level
      resumeId
    }
  """

  def create do
    """
      mutation CreateSpokenLanguage($input: CreateSpokenLanguageInput!) {
        createSpokenLanguage(input: $input) {
          ...#{@fragment_name}
        }
      }

      #{@all_fields_fragment}
    """
  end
end
