
defmodule Zenith.School do
  use Ash.Domain,
    otp_app: :zenith,
    extensions: [AshGraphql.Domain]

  graphql do
    root_level_errors? true
    authorize? true
  end

  resources do
    resource Zenith.School.Teacher
    resource Zenith.School.Student
    resource Zenith.School.Class
    resource Zenith.School.Language
    resource Zenith.School.Enrollment
    resource Zenith.School.Grade
    resource Zenith.School.Classroom
  end
end
