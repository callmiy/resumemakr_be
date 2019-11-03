defmodule Data.Repo.Migrations.ConvertToTimestamptz do
  use Ecto.Migration

  @timestamps_columns [
    "inserted_at",
    "updated_at"
  ]

  @tables [
    "credentials",
    "resumes",
    "users"
  ]

  def up do
    for time_column <- @timestamps_columns,
        table_name <- @tables do
      to_tz_col_type(table_name, time_column)
    end

    to_tz_col_type("credentials", "recovery_token_expires")
  end

  def down do
    for time_column <- @timestamps_columns,
        table_name <- @tables do
      to_timestamp_col_type(table_name, time_column)
    end

    to_timestamp_col_type("credentials", "recovery_token_expires")
  end

  def to_tz_col_type(table_name, col_name) do
    execute("""
    ALTER TABLE #{table_name}
      ALTER COLUMN #{col_name}
      TYPE TIMESTAMP WITH TIME ZONE
    USING #{col_name} AT TIME ZONE 'UTC'
    """)
  end

  def to_timestamp_col_type(table_name, col_name) do
    execute("""
    ALTER TABLE #{table_name}
      ALTER COLUMN #{col_name}
      TYPE TIMESTAMP
    USING #{col_name} AT TIME ZONE 'UTC'
    """)
  end
end
