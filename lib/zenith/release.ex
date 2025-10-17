defmodule Zenith.Release do
  @moduledoc """
  Used for performing DB operations from within the release.
  """

  require Logger

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
    :ok
  end

  def seed do
    load_app()

    seed_module = Module.concat([Zenith.Release, Seeds])

    if Code.ensure_loaded?(seed_module) do
      seed_module.run()
    end
  end

  defp repos do
    Application.fetch_env!(:zenith, :ecto_repos)
  end

  defp load_app do
    Application.load(:zenith)
  end
end
