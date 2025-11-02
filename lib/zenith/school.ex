
defmodule Zenith.School do
  use Ash.Domain,
    otp_app: :zenith,
    extensions: [AshGraphql.Domain]

  graphql do
    root_level_errors? true
    authorize? true
  end

  # https://www.drawdb.app/editor?shareId=cf56ceac6b25b0aaff370f74fb39d193

  resources do
    resource Zenith.School.Teacher
    resource Zenith.School.Student
    resource Zenith.School.Class
    resource Zenith.School.Language
    resource Zenith.School.Enrollment
    resource Zenith.School.Grade
    resource Zenith.School.Classroom
    resource Zenith.School.Lesson
    resource Zenith.School.Frequency
    resource Zenith.School.Exam
    resource Zenith.School.Topic
    resource Zenith.School.Result
    resource Zenith.School.Score
  end
end
