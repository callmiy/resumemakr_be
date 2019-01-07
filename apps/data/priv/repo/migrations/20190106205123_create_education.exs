defmodule Data.Repo.Migrations.CreateEducation do
  use Ecto.Migration

  def change do
    create table(:education) do
      add :school, :string
      add :course, :string
      add :from_date, :string
      add :to_date, :string
      add :achievements, {:array, :string}

      add :resume_id,
          references(:resumes, on_delete: :delete_all),
          null: false,
          comment: "The resume"
    end

    :education
    |> index([:resume_id])
    |> create()
  end
end
