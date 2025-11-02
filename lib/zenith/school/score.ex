defmodule Zenith.School.Score do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Score.
  """

  graphql do
    type :score

    queries do
      get :get_score, :read
      list :list_scores, :read_paginated
    end

    mutations do
      create :create_score, :create
      update :update_score, :update
      destroy :destroy_score, :destroy
    end
  end

  postgres do
    table "scores"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :score, :integer, public?: true
    attribute :feedback, :string, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
    read :read_paginated do
      pagination do
        required? false
        keyset? true
        default_limit 10
        countable true
        max_page_size 10
      end
    end
  end

  relationships do
    belongs_to :result, Zenith.School.Result, public?: true, allow_nil?: false
    belongs_to :topic, Zenith.School.Topic, public?: true, allow_nil?: false
  end
end
