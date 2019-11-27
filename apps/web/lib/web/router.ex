defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Web.Plug.Guardian.Pipeline)
    plug(Web.Plug.AbsintheContext)
  end

  if Application.get_env(:resumemakr, :is_e2e) do
    post("/iennc67hx1", Web.UtilController, :start)
  end

  scope "/" do
    pipe_through(:api)

    forward(
      "/api",
      Absinthe.Plug,
      schema: Data.Schema,
      context: %{pubsub: Web.Endpoint},
      json_codec: Jason
    )

    if Application.get_env(:web, :use_graphiql) do
      forward(
        "/___graphiql",
        Absinthe.Plug.GraphiQL,
        schema: Data.Schema,
        context: %{pubsub: Web.Endpoint},
        json_codec: Jason
      )
    end
  end
end

if Application.get_env(:resumemakr, :is_e2e) do
  defmodule Web.UtilController do
    use Web, :controller

    alias Data.Repo

    def start(conn, _) do
      Repo.truncate_all()
      json(conn, %{ok: "ok"})
    end
  end
end
