defmodule Data.Resumes.PersonalInfo do
  use Ecto.Schema
  use Arc.Ecto.Schema

  import Ecto.Changeset

  alias Data.Resumes.Resume
  alias Data.Resumes
  alias Data.Uploaders.ResumePhoto

  schema "personal_info" do
    belongs_to(:resume, Resume)
    field :first_name, :string
    field :last_name, :string
    field :address, :string
    field :email, :string
    field :phone, :string
    field :profession, :string
    field :date_of_birth, :date
    field :photo, ResumePhoto.Type
    field :delete, :boolean, virtual: true
  end

  def changeset(%__MODULE__{} = schema), do: changeset(schema, %{})
  def changeset(attrs), do: changeset(%__MODULE__{}, attrs)

  def changeset(%__MODULE__{} = schema, attrs) do
    schema
    |> cast(attrs, [
      :resume_id,
      :first_name,
      :last_name,
      :profession,
      :phone,
      :address,
      :email,
      :date_of_birth,
      :photo,
      :delete
    ])
    |> cast_attachments(attrs, [:photo])
    |> validate_required([
      :first_name,
      :last_name
    ])
    |> assoc_constraint(:resume)
    |> Resumes.maybe_mark_for_deletion()
  end

  # defp cast_photo(changeset, attrs) do

  # end
end
