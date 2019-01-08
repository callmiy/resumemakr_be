defmodule Data.SchemaTypes do
  @moduledoc """
  Custom types (scalars, objects and input types) shared among schema types
  """
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern
  use Timex

  alias Data.Accounts.User
  alias Data.Resumes.Resume
  alias Data.Resumes.Skill
  alias Data.Resumes.Experience
  alias Data.Resumes.PersonalInfo
  alias Data.Resumes.Education

  node interface do
    resolve_type(fn
      %User{}, _ ->
        :user

      %Resume{}, _ ->
        :resume

      %Skill{}, _ ->
        :skill

      %Experience{}, _ ->
        :resume_experience

      %PersonalInfo{}, _ ->
        :personal_info

      %Education{}, _ ->
        :education

      _, _ ->
        nil
    end)
  end

  @iso_extended_format "{ISO:Extended:Z}"

  scalar :iso_datetime, name: "ISODatime" do
    parse(&parse_iso_datetime/1)
    serialize(&Timex.format!(&1, @iso_extended_format))
  end

  @spec parse_iso_datetime(Absinthe.Blueprint.Input.String.t()) ::
          {:ok, DateTime.t() | NaiveDateTime.t()} | :error
  @spec parse_iso_datetime(Absinthe.Blueprint.Input.Null.t()) :: {:ok, nil}
  defp parse_iso_datetime(%Absinthe.Blueprint.Input.String{value: value}) do
    case Timex.parse(value, @iso_extended_format) do
      {:ok, val} -> {:ok, val}
      {:error, _} -> :error
    end
  end

  defp parse_iso_datetime(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  defp parse_iso_datetime(_) do
    :error
  end
end
