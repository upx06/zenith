defmodule Zenith.School.StudentTest do
  use ExUnit.Case, async: true
  require Ash.Query

  alias Zenith.Repo
  alias Zenith.School.Student
  import Zenith.Generator

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  describe "create action" do
    test "creates a valid Student" do
      params = %{
        name: "Student Name",
        email: "student@example.com",
        phone: "15999999999"
      }

      assert {:ok, %Student{} = resource} = Student |> Ash.create(params)
      assert resource.name == "Student Name"
    end

    test "fails to create a Student with invalid data" do
      params = %{name: nil}

      assert {:error, _changeset} = Student |> Ash.create(params)
    end
  end

  describe "read actions" do
    test "lists Student" do
      generate(student())

      {:ok, resources} = Student |> Ash.Query.for_read(:read_paginated) |> Ash.read()

      has_any =
        resources
        |> Enum.any?(fn resource -> resource.name == "Student Name" end)

      assert has_any == true
    end
  end

  describe "update action" do
    test "updates a Student" do
      resource = generate(student())

      params = %{name: "New Student Name"}
      assert {:ok, %Student{} = updated_resource} = resource |> Ash.update(params)
      assert updated_resource.name == "New Student Name"
    end
  end

  describe "remove action" do
    test "can be remove a Student" do
      resource = generate(student())

      assert resource |> Ash.destroy() == :ok
    end
  end
end
