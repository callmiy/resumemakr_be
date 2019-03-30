defmodule Web.UtilController do
  use Web, :controller

  alias Data.Repo

  def start(conn, _) do
    Repo.truncate_all()
    json(conn, %{ok: "ok"})
  end
end
