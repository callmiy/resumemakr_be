defmodule Data.Resolver.TextOnlyResolver do
  alias Data.Resumes.TextOnly
  alias Data.Resumes

  @spec create(
          inputs :: %{
            input: %{
              tag: atom
            }
          },
          context: map
        ) ::
          {:error, binary}
          | {
              :ok,
              TextOnly
            }
  def create(
        %{
          input: attrs
        },
        %{
          context: %{
            current_user: %{
              id: user_id
            }
          }
        }
      ) do
    create_p(user_id, attrs)
  end

  defp create_p(user_id, %{tag: :resumes_hobbies} = attrs) do
    %{
      user_id: user_id,
      id: attrs.owner_id
    }
    |> Resumes.get_resume_by()
    |> case do
      resume ->
        attrs
        |> Map.put(
          :resume,
          resume
        )
        |> Resumes.create_text_only()
    end
  end

  defp create_p(user_id, %{tag: :education_achievements} = attrs) do
    %{
      user_id: user_id,
      id: attrs.owner_id
    }
    |> Resumes.get_education()
    |> case do
      education ->
        attrs
        |> Map.put(:education, education)
        |> Resumes.create_text_only()
    end
  end
end
