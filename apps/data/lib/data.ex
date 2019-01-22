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
      "data" ->
        Path.join(path, "../..") |> Path.expand()

      _ ->
        path
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

  def plug_from_base64("data:" <> string_val) do
    with [mime, may_be_encoded_64] <-
           String.split(
             string_val,
             ";base64,",
             parts: 2
           ),
         {:ok, binary} <- Base.decode64(may_be_encoded_64) do
      [_, ext] = String.split(mime, "/", parts: 2)

      filename =
        System.os_time(:seconds)
        |> Integer.to_string()
        |> Kernel.<>(".#{ext}")

      path = Path.join([Data.umbrella_root(), "uploads", filename])

      case File.write(path, binary, [:binary]) do
        :ok ->
          {
            :ok,
            %Plug.Upload{
              filename: filename,
              content_type: mime,
              path: path
            }
          }

        _ ->
          :error
      end
    else
      _ ->
        :error
    end
  end

  def plug_from_base64(_), do: :error

  def file_to_data_uri(path, mime) do
    case File.read(path) do
      {:ok, binary} ->
        "data:#{mime};base64," <> Base.encode64(binary)

      _ ->
        nil
    end
  end
end
