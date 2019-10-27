defmodule Data.Resolver.TextOnlyResolver do
  # alias Data.Resumes.TextOnly
  alias Data.Resumes

  def create(
        %{
          input:
            %{
              tag: tag
            } = attrs
        },
        %{
          context: %{
            current_user: %{
              id: user_id
            }
          }
        }
      ) do
    create_p(tag, user_id, attrs)
  end

  defp create_p(:resumes_hobbies = tag, user_id, attrs) do
    %{
      user_id: user_id,
      id: attrs.owner_id
    }
    |> Resumes.get_resume_by()
    |> case do
      resume ->
        attrs =
          Map.put(
            attrs,
            :resume,
            resume
          )

        Resumes.create_text_only(tag, attrs)
    end
  end
end
