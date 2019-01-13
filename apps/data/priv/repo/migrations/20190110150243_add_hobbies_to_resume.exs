defmodule Data.Repo.Migrations.AddHobbiesToResume do
  use Ecto.Migration

  def change do
    alter table(:resumes) do
      add :hobbies, {:array, :text}
    end
  end
end
