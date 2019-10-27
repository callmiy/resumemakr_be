defmodule EbnisData.Repo.Migrations.ConvertToUlid do
  @moduledoc """
    1. Drop a foreign key constraint in the foreign table. E.g drop
        resumes_user_id_fkey in up/down migration of user table
    2. Recreate the foreign key constraint in up_restore_constraints and down
        migration of primary table. E.g recreate resumes_user_id_fkey in up
        restore constraint of resume table
  """
  use Ecto.Migration
  import Ecto.Query
  alias Data.Repo

  def up do
    up_user_schema()
    up_credentials_schema()
    up_resume_schema()
    up_experiences_schema()
    up_education_schema()
    up_personal_info_schema()
    up_skills_schema()

    flush()

    up_user_data()
    up_restore_constraints_user()

    up_credentials_data()
    up_restore_constraints_credentials()

    up_resumes_data()
    up_restore_constraints_resume()

    up_experiences_data()
    up_restore_constraints_experiences()

    up_education_data()
    up_restore_constraints_education()

    up_personal_info_data()
    up_restore_constraints_personal_info()

    up_skills_data()
    up_restore_constraints_skills()
  end

  def down do
    down_user_schema()
    down_credentials_schema()
    down_resume_schema()
    down_experiences_schema()
    down_education_schema()
    down_personal_info_schema()
    down_skills_schema()
  end

  defp up_user_schema do
    :resumes
    |> constraint(:resumes_user_id_fkey)
    |> drop()

    :credentials
    |> constraint(:credentials_user_id_fkey)
    |> drop()

    table = "users"

    drop_pkey_constraint(table)
    rename_column(table, :id, :old_id)

    alter table(table) do
      modify(:old_id, :bigint, null: true)
      add(:id, :binary_id)
    end
  end

  defp up_user_data do
    from(
      u in "users",
      select: u.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        u in "users",
        where: u.old_id == ^old_id,
        update: [
          set: [
            id: ^ulid_id()
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_user do
    table = "users"

    make_bin_col_not_null(table)
    create_id_pk(table)
  end

  defp down_user_schema do
    :resumes
    |> constraint(:resumes_user_id_fkey)
    |> drop()

    :credentials
    |> constraint(:credentials_user_id_fkey)
    |> drop()

    table = "users"

    drop_pkey_constraint(table)

    alter table(table) do
      remove(:id)
    end

    rename_column(table, :old_id, :id)

    alter table(table) do
      modify(:id, :bigint, null: false)
    end

    create_id_pk(table)
  end

  defp up_credentials_schema do
    table = "credentials"

    table
    |> index([:user_id, :source])
    |> drop()

    table
    |> index([:source, :token])
    |> drop()

    drop_pkey_constraint(table)
    rename_column(table, :id, :old_id)
    rename_column(table, :user_id, :old_user_id)

    alter table(table) do
      modify(:old_user_id, :bigint, null: true)
      modify(:old_id, :bigint, null: true)
      add(:id, :binary_id)
      add(:user_id, :binary_id)
    end
  end

  defp up_restore_constraints_credentials do
    table = "credentials"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :user_id)
    create_id_pk(table)
    make_col_foreign_key(table, "user_id", "users")

    table
    |> unique_index([:user_id, :source])
    |> create()

    # we will not touch it on rollback because it was originally not unique but
    # this migration corrects that and should not roll it back
    table
    |> unique_index([:source, :token])
    |> create()
  end

  defp up_credentials_data do
    from(
      c in "credentials",
      select: c.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        c in "credentials",
        where: c.old_id == ^old_id,
        join: u in "users",
        on: c.old_user_id == u.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            user_id: u.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp down_credentials_schema do
    table = "credentials"

    drop_pkey_constraint(table)

    alter table(table) do
      remove(:id)
      remove(:user_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_user_id, :user_id)

    alter table(table) do
      modify(:user_id, :bigint, null: false)
      modify(:id, :bigint, null: false)
    end

    create_id_pk(table)
    make_col_foreign_key(table, "user_id", "users")

    table
    |> unique_index([:user_id, :source])
    |> create()
  end

  defp up_resume_schema do
    :education
    |> constraint(:education_resume_id_fkey)
    |> drop()

    :experiences
    |> constraint(:experiences_resume_id_fkey)
    |> drop()

    :personal_info
    |> constraint(:personal_info_resume_id_fkey)
    |> drop()

    :skills
    |> constraint(:skills_resume_id_fkey)
    |> drop()

    table = "resumes"

    table
    |> index([:user_id])
    |> drop()

    table
    |> index([:user_id, :title])
    |> drop()

    table
    |> index([:additional_skills], name: "resumes_additional_skills")
    |> drop()

    table
    |> index([:languages], name: "resumes_languages")
    |> drop()

    drop_pkey_constraint(table)
    rename_column(table, :id, :old_id)
    rename_column(table, :user_id, :old_user_id)

    alter table(table) do
      modify(:old_user_id, :bigint, null: true)
      modify(:old_id, :bigint, null: true)
      add(:id, :binary_id)
      add(:user_id, :binary_id)
    end
  end

  defp up_resumes_data() do
    from(
      e in "resumes",
      select: e.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        e in "resumes",
        where: e.old_id == ^old_id,
        join: u in "users",
        on: e.old_user_id == u.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            user_id: u.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_resume do
    table = "resumes"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :user_id)
    create_id_pk(table)
    make_col_foreign_key(table, "user_id", "users")

    table
    |> index([:user_id])
    |> create()

    table
    |> unique_index([:user_id, :title])
    |> create()
  end

  defp down_resume_schema do
    :education
    |> constraint(:education_resume_id_fkey)
    |> drop()

    :experiences
    |> constraint(:experiences_resume_id_fkey)
    |> drop()

    :personal_info
    |> constraint(:personal_info_resume_id_fkey)
    |> drop()

    :skills
    |> constraint(:skills_resume_id_fkey)
    |> drop()

    table = "resumes"

    table
    |> index([:user_id, :title])
    |> drop()

    drop_pkey_constraint(table)

    alter table(table) do
      remove(:id)
      remove(:user_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_user_id, :user_id)

    alter table(table) do
      modify(:user_id, :bigint, null: false)
      modify(:id, :bigint, null: false)
    end

    table
    |> index([:user_id])
    |> create()

    table
    |> index([:user_id, :title])
    |> create()

    table
    |> index([:additional_skills], name: "resumes_additional_skills")
    |> create()

    table
    |> index([:languages], name: "resumes_languages")
    |> create()

    create_id_pk(table)
    make_col_foreign_key(table, "user_id", "users")
  end

  defp up_experiences_schema do
    table = "experiences"

    table
    |> index([:resume_id])
    |> drop()

    drop_pkey_constraint(table)
    rename_column(table, :id, :old_id)
    rename_column(table, :resume_id, :old_resume_id)

    alter table(table) do
      add(:id, :binary_id)
      add(:resume_id, :binary_id)
      modify(:old_id, :bigint, null: true)
      modify(:old_resume_id, :bigint, null: true)
    end
  end

  defp up_experiences_data do
    from(
      e in "experiences",
      select: e.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        e in "experiences",
        where: e.old_id == ^old_id,
        join: ex in "resumes",
        on: e.old_resume_id == ex.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            resume_id: ex.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_experiences do
    table = "experiences"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :resume_id)
    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp down_experiences_schema do
    table = "experiences"

    table
    |> index([:resume_id])
    |> drop()

    drop_pkey_constraint(table)

    alter table(table) do
      remove(:id)
      remove(:resume_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_resume_id, :resume_id)

    alter table(table) do
      modify(:id, :bigint, null: false)
      modify(:resume_id, :bigint, null: false)
    end

    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp up_education_schema do
    table = "education"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    rename_column(table, :id, :old_id)
    rename_column(table, :resume_id, :old_resume_id)

    alter table(table) do
      add(:id, :binary_id)
      add(:resume_id, :binary_id)
      modify(:old_id, :bigint, null: true)
      modify(:old_resume_id, :bigint, null: true)
    end
  end

  defp up_education_data do
    from(
      d in "education",
      select: d.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        d in "education",
        where: d.old_id == ^old_id,
        join: e in "resumes",
        on: d.old_resume_id == e.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            resume_id: e.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_education do
    table = "education"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :resume_id)
    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp down_education_schema do
    table = "education"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    alter table(table) do
      remove(:id)
      remove(:resume_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_resume_id, :resume_id)

    alter table(table) do
      modify(:id, :bigint, null: false)
      modify(:resume_id, :bigint, null: false)
    end

    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp up_personal_info_schema do
    table = "personal_info"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    rename_column(table, :id, :old_id)
    rename_column(table, :resume_id, :old_resume_id)

    alter table(table) do
      add(:id, :binary_id)
      add(:resume_id, :binary_id)
      modify(:old_id, :bigint, null: true)
      modify(:old_resume_id, :bigint, null: true)
    end
  end

  defp up_personal_info_data do
    from(
      e in "personal_info",
      select: e.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        e in "personal_info",
        where: e.old_id == ^old_id,
        join: ex in "resumes",
        on: e.old_resume_id == ex.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            resume_id: ex.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_personal_info do
    table = "personal_info"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :resume_id)
    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp down_personal_info_schema do
    table = "personal_info"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    alter table(table) do
      remove(:id)
      remove(:resume_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_resume_id, :resume_id)

    alter table(table) do
      modify(:id, :bigint, null: false)
      modify(:resume_id, :bigint, null: false)
    end

    make_col_foreign_key(table, "resume_id", "resumes")
    create_id_pk(table)

    table
    |> index([:resume_id])
    |> create()
  end

  defp up_skills_schema do
    table = "skills"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    rename_column(table, :id, :old_id)
    rename_column(table, :resume_id, :old_resume_id)

    alter table(table) do
      add(:id, :binary_id)
      add(:resume_id, :binary_id)
      modify(:old_id, :bigint, null: true)
      modify(:old_resume_id, :bigint, null: true)
    end
  end

  defp up_skills_data do
    from(
      d in "skills",
      select: d.old_id
    )
    |> Repo.all()
    |> Enum.map(fn old_id ->
      from(
        d in "skills",
        where: d.old_id == ^old_id,
        join: e in "resumes",
        on: d.old_resume_id == e.old_id,
        update: [
          set: [
            id: ^ulid_id(),
            resume_id: e.id
          ]
        ]
      )
      |> Repo.update_all([])
    end)
  end

  defp up_restore_constraints_skills do
    table = "skills"

    make_bin_col_not_null(table)
    make_bin_col_not_null(table, :resume_id)
    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp down_skills_schema do
    table = "skills"

    drop_pkey_constraint(table)

    table
    |> index([:resume_id])
    |> drop()

    alter table(table) do
      remove(:id)
      remove(:resume_id)
    end

    rename_column(table, :old_id, :id)
    rename_column(table, :old_resume_id, :resume_id)

    alter table(table) do
      modify(:id, :bigint, null: false)
      modify(:resume_id, :bigint, null: false)
    end

    create_id_pk(table)
    make_col_foreign_key(table, "resume_id", "resumes")

    table
    |> index([:resume_id])
    |> create()
  end

  defp rename_column(table, from_col, to_col) do
    table
    |> table()
    |> rename(from_col, to: to_col)
  end

  defp ulid_id() do
    Ecto.ULID.bingenerate()
  end

  defp drop_pkey_constraint(table) do
    table
    |> constraint("#{table}_pkey")
    |> drop()
  end

  defp create_id_pk(table) do
    execute("ALTER TABLE #{table} ADD PRIMARY KEY (id)")
  end

  defp make_bin_col_not_null(table, col \\ :id) do
    alter table(table) do
      modify(col, :binary_id, null: false)
    end
  end

  defp make_col_foreign_key(table, col, ref_table, ref_col \\ "id") do
    execute("""
      ALTER TABLE #{table}
      ADD CONSTRAINT #{table}_#{col}_fkey
      FOREIGN KEY (#{col})
      REFERENCES #{ref_table} (#{ref_col})
      ON DELETE CASCADE
    """)
  end
end
