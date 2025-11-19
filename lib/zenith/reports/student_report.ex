defmodule Zenith.Reports.StudentReport do
  @moduledoc """
  Gera relatório completo de aluno em PDF
  """

  require Ash.Query

  def generate(student_id) do
    with {:ok, data} <- fetch_student_data(student_id),
         {:ok, html} <- render_html(data),
         {:ok, pdf_path} <- generate_pdf(html, student_id) do
      {:ok, pdf_path}
    end
  end

  defp fetch_student_data(student_id) do
    case Zenith.School.Student
         |> Ash.Query.filter(id == ^student_id)
         |> Ash.Query.load([
           :name,
           :email,
           :phone,
           :goal,
           enrollment: [
             :class,
             frequencies: [:lesson],
             scores: [:score, :feedback, :exam, :topic]
           ]
         ])
         |> Ash.read_one(authorize?: false) do
      {:ok, nil} ->
        {:error, :not_found}

      {:ok, student} ->
        format_data(student)

      {:error, error} ->
        {:error, error}
    end
  end

  defp format_data(student) do
    enrollment = List.first(student.enrollment)

    if enrollment do
      # Agrupar scores por exame
      scores_by_exam = Enum.group_by(enrollment.scores, & &1.exam_id)

      # Calcular média geral
      total_scores = length(enrollment.scores)
      average = if total_scores > 0 do
        sum = Enum.sum(Enum.map(enrollment.scores, & &1.score))
        Float.round(sum / total_scores, 1)
      else
        0
      end

      # Calcular estatísticas de frequência
      total_lessons = length(enrollment.frequencies)
      attended_lessons = Enum.count(enrollment.frequencies, & &1.attendance)
      attendance_rate = if total_lessons > 0 do
        Float.round((attended_lessons / total_lessons) * 100, 1)
      else
        0
      end

      # Calcular aprovação/reprovação por nota
      passing_scores = Enum.count(enrollment.scores, & &1.score >= 7)
      failing_scores = Enum.count(enrollment.scores, & &1.score < 5)

      {:ok, %{
        student: student,
        class: enrollment.class,
        enrollment: enrollment,
        scores_by_exam: scores_by_exam,
        total_scores: total_scores,
        average: average,
        total_lessons: total_lessons,
        attended_lessons: attended_lessons,
        attendance_rate: attendance_rate,
        passing_scores: passing_scores,
        failing_scores: failing_scores
      }}
    else
      {:error, :not_found}
    end
  end

  defp render_html(data) do
    logo_url = get_logo_url()

    html = EEx.eval_string(
      template(),
      assigns: [
        student: data.student,
        class: data.class,
        enrollment: data.enrollment,
        scores_by_exam: data.scores_by_exam,
        total_scores: data.total_scores,
        average: data.average,
        total_lessons: data.total_lessons,
        attended_lessons: data.attended_lessons,
        attendance_rate: data.attendance_rate,
        passing_scores: data.passing_scores,
        failing_scores: data.failing_scores,
        score_class: &score_class/1,
        display_feedback: &display_feedback/1,
        logo_url: logo_url
      ]
    )
    {:ok, html}
  end

  defp generate_pdf(html, student_id) do
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    filename = "student_report_#{student_id}_#{timestamp}.pdf"

    tmp_dir = Path.join([System.tmp_dir!(), "zenith_reports"])
    File.mkdir_p!(tmp_dir)

    output_path = Path.join(tmp_dir, filename)

    case ChromicPDF.print_to_pdf(
      {:html, html},
      output: output_path,
      print_to_pdf: %{
        preferCSSPageSize: true,
        printBackground: true,
        marginTop: 0.4,
        marginBottom: 0.4,
        marginLeft: 0.4,
        marginRight: 0.4
      }
    ) do
      :ok -> {:ok, output_path}
      _ -> {:error, "Error generating PDF"}
    end
  end

  # Helpers
  defp score_class(score) when score >= 7, do: "text-success"
  defp score_class(score) when score >= 5, do: "text-warning"
  defp score_class(_score), do: "text-danger"

  defp display_feedback(""), do: "-"
  defp display_feedback(nil), do: "-"
  defp display_feedback(feedback), do: feedback

  defp get_logo_url do
    # "https://rejoy-public.s3.sa-east-1.amazonaws.com/logo.jpg"
    "https://rejoy-public.s3.sa-east-1.amazonaws.com/logo-png.png"
    # "https://rejoy-public.s3.sa-east-1.amazonaws.com/logo-png-v.png"
    # "https://rejoy-public.s3.sa-east-1.amazonaws.com/logo-png-h.png"
    # "https://rejoy-public.s3.sa-east-1.amazonaws.com/logo-png-dark.png"
  end

  defp template do
    """
    <!DOCTYPE html>
    <html lang="pt-BR">
    <head>
      <meta charset="UTF-8">
      <title>Relatório Acadêmico - Zenith English School</title>
      <style>
        :root {
          --primary: #1e3a8a;
          --primary-dark: #1e293b;
          --primary-light: #3b82f6;
          --accent: #0ea5e9;
          --success: #059669;
          --success-light: #d1fae5;
          --warning: #d97706;
          --warning-light: #fef3c7;
          --danger: #b91c1c;
          --danger-light: #fecaca;
          --gray-50: #f8fafc;
          --gray-100: #f1f5f9;
          --gray-200: #e2e8f0;
          --gray-300: #cbd5e1;
          --gray-400: #94a3b8;
          --gray-500: #64748b;
          --gray-600: #475569;
          --gray-700: #334155;
          --gray-800: #1e293b;
          --gray-900: #0f172a;
          --white: #ffffff;
        }

        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }

        @page {
          size: A4;
          margin: 0;
        }

        html {
          height: 100%;
        }

        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
          color: var(--gray-800);
          line-height: 1.5;
          background: var(--white);
          font-size: 14px;
          min-height: 100%;
          display: flex;
          flex-direction: column;
        }

        /* Header profissional */
        .header {
          background: var(--white);
          border-bottom: 4px solid var(--primary);
          padding: 30px 40px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .header-left {
          flex: 1;
        }

        .header-logo {
          max-height: 60px;
          width: auto;
        }

        .header-right {
          text-align: right;
        }

        .document-title {
          font-size: 22px;
          font-weight: 700;
          color: var(--primary-dark);
          margin-bottom: 4px;
          letter-spacing: -0.5px;
        }

        .document-subtitle {
          font-size: 13px;
          color: var(--gray-600);
          font-weight: 500;
        }

        .page-wrapper {
          flex: 1;
          display: flex;
          flex-direction: column;
        }

        .container {
          padding: 40px;
          flex: 1;
        }

        /* Seção de informações do aluno */
        .student-info-card {
          background: var(--gray-50);
          border: 1px solid var(--gray-200);
          border-radius: 4px;
          padding: 28px 32px;
          margin-bottom: 32px;
        }

        .info-grid {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 24px 32px;
        }

        .info-item {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .info-label {
          font-weight: 600;
          color: var(--gray-500);
          font-size: 11px;
          text-transform: uppercase;
          letter-spacing: 0.8px;
        }

        .info-value {
          color: var(--gray-900);
          font-size: 15px;
          font-weight: 500;
        }

        /* Cards de estatísticas */
        .stats-grid {
          display: grid;
          grid-template-columns: repeat(4, 1fr);
          gap: 16px;
          margin-bottom: 36px;
        }

        .stat-card {
          background: var(--white);
          border: 1px solid var(--gray-200);
          border-radius: 4px;
          padding: 20px 16px;
          text-align: center;
        }

        .stat-card.highlight {
          border-left: 4px solid var(--primary);
        }

        .stat-label {
          font-size: 11px;
          color: var(--gray-500);
          text-transform: uppercase;
          font-weight: 600;
          letter-spacing: 0.6px;
          margin-bottom: 8px;
        }

        .stat-value {
          font-size: 32px;
          font-weight: 700;
          color: var(--gray-900);
          line-height: 1;
        }

        .stat-value.medium {
          font-size: 26px;
        }

        .stat-value.success {
          color: var(--success);
        }

        .stat-value.warning {
          color: var(--warning);
        }

        .stat-value.danger {
          color: var(--danger);
        }

        /* Seções */
        .section {
          margin-bottom: 40px;
          page-break-inside: avoid;
        }

        .section-header {
          margin-bottom: 20px;
          padding-bottom: 10px;
          border-bottom: 2px solid var(--gray-300);
        }

        .section-title {
          font-size: 18px;
          font-weight: 700;
          color: var(--primary-dark);
          text-transform: uppercase;
          letter-spacing: 0.5px;
        }

        /* Progress bar profissional */
        .progress-container {
          margin-bottom: 36px;
        }

        .progress-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 8px;
        }

        .progress-label {
          font-size: 13px;
          font-weight: 600;
          color: var(--gray-700);
        }

        .progress-value {
          font-size: 14px;
          font-weight: 700;
          color: var(--primary);
        }

        .progress-bar {
          width: 100%;
          height: 8px;
          background: var(--gray-200);
          border-radius: 4px;
          overflow: hidden;
        }

        .progress-fill {
          height: 100%;
          background: var(--primary);
          transition: width 0.3s ease;
        }

        /* Tabelas profissionais */
        .exam-group {
          margin-bottom: 28px;
          page-break-inside: avoid;
        }

        .exam-header {
          background: var(--primary-dark);
          color: var(--white);
          padding: 12px 20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          font-weight: 600;
          font-size: 14px;
        }

        .exam-average {
          font-size: 13px;
          opacity: 0.95;
        }

        table {
          width: 100%;
          border-collapse: collapse;
          background: var(--white);
          border: 1px solid var(--gray-300);
        }

        thead {
          background: var(--gray-100);
        }

        th {
          padding: 12px 16px;
          text-align: left;
          font-weight: 600;
          font-size: 11px;
          color: var(--gray-600);
          text-transform: uppercase;
          letter-spacing: 0.6px;
          border-bottom: 2px solid var(--gray-300);
        }

        td {
          padding: 12px 16px;
          border-bottom: 1px solid var(--gray-200);
          font-size: 13px;
          color: var(--gray-700);
        }

        tbody tr:last-child td {
          border-bottom: none;
        }

        tbody tr:nth-child(even) {
          background: var(--gray-50);
        }

        /* Score badges profissionais */
        .score-badge {
          display: inline-flex;
          align-items: center;
          justify-content: center;
          min-width: 50px;
          padding: 4px 10px;
          border-radius: 3px;
          font-weight: 700;
          font-size: 14px;
          border: 1px solid;
        }

        .text-success {
          color: var(--success);
          background: var(--success-light);
          border-color: var(--success);
        }

        .text-warning {
          color: var(--warning);
          background: var(--warning-light);
          border-color: var(--warning);
        }

        .text-danger {
          color: var(--danger);
          background: var(--danger-light);
          border-color: var(--danger);
        }

        /* Attendance grid profissional */
        .attendance-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(90px, 1fr));
          gap: 8px;
        }

        .attendance-item {
          background: var(--white);
          border: 1px solid var(--gray-300);
          border-radius: 3px;
          padding: 10px 8px;
          text-align: center;
          font-size: 12px;
        }

        .attendance-item.present {
          border-color: var(--success);
          background: var(--success-light);
        }

        .attendance-item.absent {
          border-color: var(--danger);
          background: var(--danger-light);
        }

        .attendance-status {
          font-weight: 700;
          font-size: 11px;
          text-transform: uppercase;
          letter-spacing: 0.5px;
          margin-bottom: 4px;
        }

        .attendance-item.present .attendance-status {
          color: var(--success);
        }

        .attendance-item.absent .attendance-status {
          color: var(--danger);
        }

        .attendance-date {
          font-size: 11px;
          color: var(--gray-600);
          font-weight: 500;
        }

        /* Summary cards */
        .summary-grid {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 20px;
          background: var(--gray-50);
          padding: 28px;
          border: 1px solid var(--gray-200);
          border-radius: 4px;
        }

        .summary-item {
          text-align: center;
        }

        .summary-label {
          font-size: 11px;
          color: var(--gray-600);
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.6px;
          margin-bottom: 8px;
        }

        .summary-value {
          font-size: 36px;
          font-weight: 700;
          line-height: 1;
        }

        .summary-item:nth-child(1) .summary-value {
          color: var(--success);
        }

        .summary-item:nth-child(2) .summary-value {
          color: var(--warning);
        }

        .summary-item:nth-child(3) .summary-value {
          color: var(--danger);
        }

        /* Footer profissional */
        .footer {
          background: var(--gray-900);
          color: var(--gray-400);
          padding: 24px 40px;
          text-align: center;
          font-size: 11px;
          line-height: 1.6;
          margin-top: auto;
          flex-shrink: 0;
        }

        .footer-title {
          color: var(--white);
          font-weight: 600;
          margin-bottom: 8px;
          font-size: 12px;
        }

        .footer p {
          margin: 3px 0;
        }

        .divider {
          height: 1px;
          background: var(--gray-300);
          margin: 32px 0;
        }
      </style>
    </head>
    <body>
      <div class="page-wrapper">
        <!-- Header -->
        <div class="header">
          <div class="header-left">
            <img src="<%= @logo_url %>" alt="Zenith English School" class="header-logo">
          </div>
          <div class="header-right">
            <div class="document-title">Relatório Acadêmico</div>
            <div class="document-subtitle">Emitido em <%= Calendar.strftime(DateTime.utc_now(), "%d/%m/%Y") %></div>
          </div>
        </div>

        <div class="container">
        <!-- Informações do Aluno -->
        <div class="student-info-card">
          <div class="info-grid">
            <div class="info-item">
              <span class="info-label">Aluno</span>
              <span class="info-value"><%= @student.name %></span>
            </div>
            <div class="info-item">
              <span class="info-label">E-mail</span>
              <span class="info-value"><%= @student.email %></span>
            </div>
            <div class="info-item">
              <span class="info-label">Telefone</span>
              <span class="info-value"><%= @student.phone || "—" %></span>
            </div>
            <div class="info-item">
              <span class="info-label">Turma</span>
              <span class="info-value"><%= @class.name %></span>
            </div>
            <div class="info-item">
              <span class="info-label">Objetivo</span>
              <span class="info-value"><%= @student.goal || "Não especificado" %></span>
            </div>
            <div class="info-item">
              <span class="info-label">Período Avaliado</span>
              <span class="info-value"><%= DateTime.utc_now().year %></span>
            </div>
          </div>
        </div>

        <!-- Estatísticas Principais -->
        <div class="stats-grid">
          <div class="stat-card highlight">
            <div class="stat-label">Média Geral</div>
            <div class="stat-value <%= cond do
              @average >= 7 -> "success"
              @average >= 5 -> "warning"
              true -> "danger"
            end %>"><%= @average %></div>
          </div>

          <div class="stat-card">
            <div class="stat-label">Total de Provas</div>
            <div class="stat-value"><%= map_size(@scores_by_exam) %></div>
          </div>

          <div class="stat-card">
            <div class="stat-label">Taxa de Presença</div>
            <div class="stat-value medium <%= if @attendance_rate >= 75, do: "success", else: "danger" %>"><%= @attendance_rate %>%</div>
          </div>

          <div class="stat-card">
            <div class="stat-label">Aulas Assistidas</div>
            <div class="stat-value medium"><%= @attended_lessons %>/<%= @total_lessons %></div>
          </div>
        </div>

        <!-- Progress Bar de Frequência -->
        <div class="progress-container">
          <div class="progress-header">
            <span class="progress-label">Taxa de Frequência</span>
            <span class="progress-value"><%= @attendance_rate %>%</span>
          </div>
          <div class="progress-bar">
            <div class="progress-fill" style="width: <%= @attendance_rate %>%;"></div>
          </div>
        </div>

        <div class="divider"></div>

        <!-- Desempenho Detalhado -->
        <div class="section">
          <div class="section-header">
            <h2 class="section-title">Desempenho Acadêmico Detalhado</h2>
          </div>

          <%= for {_exam_id, scores} <- @scores_by_exam do %>
            <% exam = List.first(scores).exam %>
            <% exam_avg = Float.round(Enum.sum(Enum.map(scores, & &1.score)) / length(scores), 1) %>

            <div class="exam-group">
              <div class="exam-header">
                <span><%= exam.name %></span>
                <span class="exam-average">Média: <%= exam_avg %></span>
              </div>

              <table>
                <thead>
                  <tr>
                    <th style="width: 45%;">Tópico Avaliado</th>
                    <th style="width: 12%; text-align: center;">Nota</th>
                    <th style="width: 43%;">Observações</th>
                  </tr>
                </thead>
                <tbody>
                  <%= for score <- scores do %>
                    <tr>
                      <td><strong><%= score.topic.name %></strong></td>
                      <td style="text-align: center;">
                        <span class="score-badge <%= @score_class.(score.score) %>">
                          <%= score.score %>
                        </span>
                      </td>
                      <td><%= @display_feedback.(score.feedback) %></td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>
          <% end %>
        </div>

        <div class="divider"></div>

        <!-- Resumo de Desempenho -->
        <div class="section">
          <div class="section-header">
            <h2 class="section-title">Distribuição de Desempenho</h2>
          </div>

          <div class="summary-grid">
            <div class="summary-item">
              <div class="summary-label">Aprovado (≥7.0)</div>
              <div class="summary-value"><%= @passing_scores %></div>
            </div>

            <div class="summary-item">
              <div class="summary-label">Regular (5.0-6.9)</div>
              <div class="summary-value"><%= @total_scores - @passing_scores - @failing_scores %></div>
            </div>

            <div class="summary-item">
              <div class="summary-label">Insuficiente (<5.0)</div>
              <div class="summary-value"><%= @failing_scores %></div>
            </div>
          </div>
        </div>

        <div class="divider"></div>

        <!-- Histórico de Frequência -->
        <div class="section">
          <div class="section-header">
            <h2 class="section-title">Registro de Frequência</h2>
          </div>

          <div class="attendance-grid">
            <%= for freq <- Enum.sort_by(@enrollment.frequencies, & &1.lesson.datetime, :desc) do %>
              <div class="attendance-item <%= if freq.attendance, do: "present", else: "absent" %>">
                <div class="attendance-status">
                  <%= if freq.attendance, do: "Presente", else: "Ausente" %>
                </div>
                <div class="attendance-date">
                  <%= Calendar.strftime(freq.lesson.datetime, "%d/%m/%Y") %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
        </div>
      </div>
    </body>
    </html>
    """
  end

      # <div class="footer">
      #   <div class="footer-title">ZENITH ENGLISH SCHOOL</div>
      #   <p>Documento gerado automaticamente pelo Sistema Acadêmico Zenith</p>
      #   <p>© <%= DateTime.utc_now().year %> Zenith English School. Todos os direitos reservados.</p>
      #   <p>Este documento é confidencial e destina-se exclusivamente ao uso do aluno e seus responsáveis legais.</p>
      # </div>
end
