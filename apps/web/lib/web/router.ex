defmodule Web.Router do
  use Web, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(Web.Plug.Guardian.Pipeline)
    plug(Web.Plug.AbsintheContext)
  end

  if Mix.env() != :prod do
    pipeline :util do
      plug(:accepts, ["json"])
    end

    scope "/iennc67hx1" do
      pipe_through(:util)

      post("/", Web.UtilController, :start)
    end
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

    if Mix.env() == :dev do
      forward(
        "/graphql",
        Absinthe.Plug.GraphiQL,
        schema: Data.Schema,
        context: %{pubsub: Web.Endpoint},
        json_codec: Jason
      )
    end
  end
end
