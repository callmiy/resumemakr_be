defmodule Data.Resumes.PersonalInfo do
  use Ecto.Schema
  import Ecto.Changeset

  alias Data.Resumes.Resume

  schema "personal_info" do
    belongs_to(:resume, Resume)
    field :first_name, :string
    field :last_name, :string
    field :address, :string
    field :email, :string
    field :phone, :string
    field :profession, :string
    field :date_of_birth, :date
    field :photo, :string
  end

  def changeset(%__MODULE__{} = personal_info, attrs \\ %{}) do
    personal_info
    |> cast(attrs, [
      :resume_id,
      :first_name,
      :last_name,
      :profession,
      :phone,
      :address,
      :email,
      :date_of_birth,
      :photo
    ])
    |> validate_required([
      :first_name,
      :last_name
    ])
    |> assoc_constraint(:resume)
  end
end
