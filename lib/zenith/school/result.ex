defmodule Zenith.School.Result do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Result.
  """

  graphql do
    type :result

    queries do
      get :get_result, :read
      list :list_results, :read_paginated
    end

    mutations do
      create :create_result, :create
      update :update_result, :update
      destroy :destroy_result, :destroy
    end
  end

  postgres do
    table "results"
    repo Zenith.Repo
  end

  actions do
    defaults [:read, :destroy]

    read :read_paginated do
      pagination do
        required? false
        keyset? true
        default_limit 10
        countable true
        max_page_size 10
      end
    end

    create :create do
      accept [:*]
      upsert? true

      argument :scores, {:array, :map}, allow_nil?: true
    end

    update :update do
      require_atomic? false
      accept [:*]

      argument :scores, {:array, :map}, allow_nil?: true
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :total_score, :integer, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
  end
end
