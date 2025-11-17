defmodule Zenith.School.Topic do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Topic.
  """

  graphql do
    type :topic

    queries do
      get :get_topic, :read
      list :list_topics, :read_paginated
    end

    mutations do
      create :create_topic, :create
      update :update_topic, :update
      destroy :destroy_topic, :destroy
    end
  end

  postgres do
    table "topics"
    repo Zenith.Repo
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

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :exam, Zenith.School.Exam, public?: true, allow_nil?: false
  end
end
