defmodule Zenith.School.ClassTest do
  use ExUnit.Case, async: true
  require Ash.Query

  alias Zenith.Repo
  alias Zenith.School.Class
  import Zenith.Generator

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  describe "create action" do
    test "creates a valid Class" do
      params = %{
        name: "Turma 01",
        level: :A1,
        language_id: generate(language()).id
      }

      assert {:ok, %Class{} = resource} = Class |> Ash.create(params)
      assert resource.level == :A1
    end

    test "fails to create a Class with invalid data" do
      params = %{level: nil}

      assert {:error, _changeset} = Class |> Ash.create(params)
    end
  end

  describe "read actions" do
    test "lists Class" do
      generate(class())

      {:ok, resources} = Class |> Ash.Query.for_read(:read_paginated) |> Ash.read()

      has_any =
        resources
        |> Enum.any?(fn resource -> resource.level == :A1 end)

      assert has_any == true
    end
  end

  describe "update action" do
    test "updates a Class" do
      resource = generate(class())

      params = %{level: :B2}
      assert {:ok, %Class{} = updated_resource} = resource |> Ash.update(params)
      assert updated_resource.level == :B2
    end
  end

  describe "remove action" do
    test "can be remove a Class" do
      resource = generate(class())

      assert resource |> Ash.destroy() == :ok
    end
  end

  describe "relationships" do
  end
end
