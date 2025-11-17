defmodule ZenithWeb.ReportController do
  use ZenithWeb, :controller

  alias Zenith.Reports.StudentReport

  def generate_student_report(conn, %{"student_id" => student_id}) do
    case StudentReport.generate(student_id) do
      {:ok, pdf_path} ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"student_report.pdf\"")
        |> send_file(200, pdf_path)
        |> then(fn conn ->
          # Limpa o arquivo temporário após o envio
          File.rm(pdf_path)
          conn
        end)

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Student not found"})

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to generate report: #{inspect(reason)}"})
    end
  end
end
