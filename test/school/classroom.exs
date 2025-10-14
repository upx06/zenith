defmodule Zenith.School.ClassroomTest do
  use ExUnit.Case, async: true
  require Ash.Query

  alias Zenith.Repo
  alias Zenith.School.Classroom
  import Zenith.Generator

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  describe "create action" do
    test "creates a valid Classroom" do
      params = %{
        name: "Sala 01",
        capacity: 10
      }

      assert {:ok, %Classroom{} = resource} = Classroom |> Ash.create(params)
      assert resource.name == "Sala 01"
    end

    test "fails to create a Classroom with invalid data" do
      params = %{name: nil}

      assert {:error, _changeset} = Classroom |> Ash.create(params)
    end
  end

  describe "read actions" do
    test "lists Classroom" do
      generate(classroom())

      {:ok, resources} = Classroom |> Ash.Query.for_read(:read_paginated) |> Ash.read()

      has_any =
        resources
        |> Enum.any?(fn resource -> resource.name == "Sala 01" end)

      assert has_any == true
    end
  end

  describe "update action" do
    test "updates a Classroom" do
      resource = generate(classroom())

      params = %{name: "Sala 02"}
      assert {:ok, %Classroom{} = updated_resource} = resource |> Ash.update(params)
      assert updated_resource.name == "Sala 02"
    end
  end

  describe "remove action" do
    test "can be remove a Classroom" do
      resource = generate(classroom())

      assert resource |> Ash.destroy() == :ok
    end
  end

  describe "relationships" do
  end
end
