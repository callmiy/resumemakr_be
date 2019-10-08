defmodule Data do
  require Logger

  @moduledoc """
  Data keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @umbrella_base System.get_env("APP_ROOT") || "be"

  def umbrella_root do
    path = Path.expand(".")

    case Path.basename(path) do
      @umbrella_base ->
        path

      _ ->
        Path.join(path, "../..") |> Path.expand()
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

  def plug_from_base64("data:" <> string_val = data) do
    Logger.info(fn ->
      [
        "\n\n\nConverting base64 string: '",
        String.slice(data, 0..60),
        "...' to plug."
      ]
    end)

    with [mime, may_be_encoded_64] <-
           String.split(
             string_val,
             ";base64,",
             parts: 2
           ),
         {:ok, binary} <- Base.decode64(may_be_encoded_64) do
      [_, ext] = String.split(mime, "/", parts: 2)

      filename =
        System.os_time(:second)
        |> Integer.to_string()
        |> Kernel.<>(".#{ext}")

      path = Path.join([umbrella_root(), "uploads", filename])

      case File.write(path, binary, [:binary]) do
        :ok ->
          Logger.info(fn ->
            [
              "Converting base64 string: ",
              "writing file: '",
              path,
              "'. Ok.\n\n\n"
            ]
          end)

          {
            :ok,
            %Plug.Upload{
              filename: filename,
              content_type: mime,
              path: path
            }
          }

        _ ->
          Logger.info(fn ->
            [
              "Converting base64 string: ",
              "writing file: '",
              path,
              "'. Error.\n"
            ]
          end)

          :error
      end
    else
      _ ->
        Logger.error(fn ->
          [
            "Converting base64 string: ",
            "Ok."
          ]
        end)

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

  def prettify_with_new_line(data, break_on \\ ~S(\n)) do
    data
    |> String.split(break_on)
    |> Enum.map(&[&1, "\n"])
  end
end
