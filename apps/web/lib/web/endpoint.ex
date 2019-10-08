defmodule Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :web

  socket "/socket", Web.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: true

  @upload_dir Path.expand("./../../uploads")

  # in dev and test
  plug Plug.Static,
    at: "/uploads",
    from: @upload_dir,
    gzip: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :web,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [
      :urlencoded,
      :multipart,
      :json,
      Absinthe.Plug.Parser
    ],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  plug Corsica,
    origins: "*",
    allow_headers: ~w(Accept Content-Type Authorization Origin)

  plug Web.Router
end
