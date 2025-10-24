defmodule ZenithWeb.GetPresignedUrlS3 do
  use ZenithWeb, :controller

  def get_profile_photo(conn, %{"key" => key}) do
    bucket = "rejoy-zenith"

    get_presigned_url_s3(conn, bucket, key)
  end

  defp get_presigned_url_s3(conn, bucket, key) do
    case ExAws.S3.presigned_url(ExAws.Config.new(:s3), :get, bucket, key) do
      {:ok, url} ->
        conn
        |> put_status(:ok)
        |> json(%{url: url})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Cannot get file"})
    end
  end
end
