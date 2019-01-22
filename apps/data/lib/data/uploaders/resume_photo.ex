defmodule Data.Uploaders.ResumePhoto do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  use Arc.Ecto.Definition

  @versions [:original]

  # To add a thumbnail version:
  @versions [:original, :thumb]

  @extension_whitelist ~w(.jpg .jpeg .gif .png)

  @storage_dir "#{Application.get_env(:arc, :storage_dir)}/resume"

  # Override the bucket on a per definition basis:
  # def bucket dofile_name
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(@extension_whitelist, file_extension)
  end

  # Define a thumbnail transformation:
  @spec transform(any(), any()) :: :noaction | {:convert, <<_::560>>, :png}
  def transform(:thumb, {_file, _resource}) do
    {
      :convert,
      "-strip -thumbnail 250x250^ -gravity center -extent 250x250 -format png",
      :png
    }
  end

  def filename(version, {file, _resource}) do
    file_name = String.replace(file.file_name, ~r/[\s\(\)]/, "_")
    ext_name = Path.extname(file_name)
    new_file_name = Path.basename(file_name, ext_name)

    case version do
      :original ->
        new_file_name

      _ ->
        "___#{version}___#{new_file_name}"
    end
  end

  # Override the storage directory:
  def storage_dir(_version, _file_and_resource) do
    @storage_dir
  end



  def storage_dir, do: @storage_dir

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
