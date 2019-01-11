defmodule Data do
  @moduledoc """
  Data keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def umbrella_root do
    path = Path.expand(".")

    case Path.basename(path) do
      "be" ->
        path

      _ ->
        Path.join(path, "../..")
        |> Path.expand()
    end
  end

  @doc ~S"""
    Since this is an umbrella app, accessing the filesystem can be tricky
    depending on from where we are making the access.  Generally, we could be
    accessing from the root of the umbrella project or from the data app.
  """
  @spec app_root() :: binary()
  def app_root do
    Path.join(umbrella_root(), "apps/data")
  end
end
