defmodule ZenithWeb.UploadFileS3 do
  use ZenithWeb, :controller

  def upload_profile_photo(conn, %{"file" => %Plug.Upload{} = file}) do
    bucket = "rejoy-zenith"
    key = "profile-photo/#{Ecto.UUID.generate()}"
    [type | extension] = String.split(file.content_type, "/")

    full_key = "#{key}.#{extension}"

    upload_to_s3(conn, bucket, full_key, type, file.path)
  end

  defp upload_to_s3(conn, bucket, key, type, file_path) do
    case File.read(file_path) do
      {:ok, file_content} ->
        operation = ExAws.S3.put_object(bucket, key, file_content, content_type: type)

        case ExAws.request(operation) do
          {:ok, %{status_code: 200}} ->
            conn
            |> put_status(:created)
            |> json(%{message: "ok", key: key})

          {:error, _reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{error: "Upload failed"})
        end

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Cannot read file"})
    end
  end
end
