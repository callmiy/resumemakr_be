defmodule Data.Repo.Migrations.CreateEducation do
  use Ecto.Migration

  def change do
    create table(:education) do
      add :school, :string
      add :course, :string
      add :from_date, :string
      add :to_date, :string
      add :achievements, {:array, :text}
      add :index, :integer, null: false, default: 1

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
