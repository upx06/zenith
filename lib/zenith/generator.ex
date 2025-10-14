defmodule Zenith.Generator do
  use Ash.Generator

  def student(opts \\ []) do
    seed_generator(
      %Zenith.School.Student{
        name: "Student Name",
        email: "student@example.com",
        phone: "15999999999"
      },
      overrides: opts
    )
  end

  def language(opts \\ []) do
    seed_generator(
      %Zenith.School.Language{
        name: "English"
      },
      overrides: opts
    )
  end

  def class(opts \\ []) do
    seed_generator(
      %Zenith.School.Class{
        name: "Turma 01",
        level: :A1,
        language_id: generate(language()).id
      },
      overrides: opts
    )
  end

  def classroom(opts \\ []) do
    seed_generator(
      %Zenith.School.Classroom{
        name: "Sala 01",
        capacity: 10
      },
      overrides: opts
    )
  end
end
