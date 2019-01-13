defmodule Data.Repo.Migrations.CreateExperiences do
  use Ecto.Migration

  def change do
    create table(:experiences) do
      add :position, :text
      add :company_name, :string
      add :from_date, :string
      add :to_date, :string
      add :achievements, {:array, :text}
      add :index, :integer, null: false, default: 1

      add :resume_id,
          references(:resumes, on_delete: :delete_all),
          null: false,
          comment: "The resume"
    end

    :experiences
    |> index([:resume_id])
    |> create()
  end
end
