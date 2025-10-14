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
end
