defmodule ZenithWeb.UploadProfilePhotoController do
  use ZenithWeb, :controller

  def upload_profile_photo(conn, %{"file" => %Plug.Upload{} = file}) do
    bucket = "rejoy-zenith"
    path = "profile-photo"
    key = Ecto.UUID.generate()
    [type | extension] = String.split(file.content_type, "/")

    file_path = file.path
    full_key = "#{path}/#{key}.#{extension}"

    case File.read(file_path) do
      {:ok, file_content} ->
        operation = ExAws.S3.put_object(bucket, full_key, file_content, content_type: type)

        case ExAws.request(operation) do
          {:ok, %{status_code: 200}} ->
            conn
            |> put_status(:created)
            |> json(%{message: "ok", key: full_key})

          {:error, reason} ->
            IO.inspect(reason)
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "error", reason: reason})
        end
    end
  end
end
