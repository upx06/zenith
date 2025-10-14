defmodule Zenith.School.LanguageTest do
  use ExUnit.Case, async: true
  require Ash.Query

  alias Zenith.Repo
  alias Zenith.School.Language
  import Zenith.Generator

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  describe "create action" do
    test "creates a valid Language" do
      params = %{
        name: "English"
      }

      assert {:ok, %Language{} = resource} = Language |> Ash.create(params)
      assert resource.name == "English"
    end

    test "fails to create a Language with invalid data" do
      params = %{name: nil}

      assert {:error, _changeset} = Language |> Ash.create(params)
    end
  end

  describe "read actions" do
    test "lists Language" do
      generate(language())

      {:ok, resources} = Language |> Ash.Query.for_read(:read_paginated) |> Ash.read()

      has_any =
        resources
        |> Enum.any?(fn resource -> resource.name == "English" end)

      assert has_any == true
    end
  end

  describe "update action" do
    test "updates a Language" do
      resource = generate(language())

      params = %{name: "Spanish"}
      assert {:ok, %Language{} = updated_resource} = resource |> Ash.update(params)
      assert updated_resource.name == "Spanish"
    end
  end

  describe "remove action" do
    test "can be remove a Language" do
      resource = generate(language())

      assert resource |> Ash.destroy() == :ok
    end
  end

  describe "relationships" do
  end
end
