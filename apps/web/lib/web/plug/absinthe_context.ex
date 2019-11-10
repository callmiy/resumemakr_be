defmodule Web.Plug.AbsintheContext do
  @behaviour Plug

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, _) do
    case Data.Guardian.Plug.current_resource(conn) do
      nil ->
        conn

      user ->
        Absinthe.Plug.put_options(conn, context: %{current_user: user})
    end
  end
end
