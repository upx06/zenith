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

  attributes do
    uuid_v7_primary_key :id

    attribute :total_score, :integer, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
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
      upsert_identity :result_identity
      upsert_fields [:total_score, :updated_at]

      argument :scores, {:array, :map}, allow_nil?: true
      change manage_relationship(:scores,
        on_no_match: {:create, :create},
        on_match: :update,
        use_identities: [:score_identity]
      )
    end

    update :update do
      require_atomic? false
      accept [:*]

      argument :scores, {:array, :map}, allow_nil?: true
      change manage_relationship(:scores,
        on_no_match: {:create, :create},
        on_match: :update,
        use_identities: [:score_identity]
      )
    end
  end

  relationships do
    belongs_to :exam, Zenith.School.Exam, public?: true, allow_nil?: false
    belongs_to :enrollment, Zenith.School.Enrollment, public?: true, allow_nil?: false
    has_many :scores, Zenith.School.Score, public?: true
  end

  identities do
    identity :result_identity, [:exam_id, :enrollment_id]
  end
end
