defmodule Zenith.School.Grade do
  use Ash.Resource,
  otp_app: :nexus,
  domain: Zenith.School,
  authorizers: [Ash.Policy.Authorizer],
  data_layer: AshPostgres.DataLayer,
  extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Grade.
  """

  graphql do
    type :grade

    queries do
      get :get_grade, :read
      list :list_grade, :read_paginated
    end

    mutations do
      create :create_grade, :create
      update :update_grade, :update
    end
  end

  postgres do
    table "grades"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    # create_timestamp :created_at, public?: true
    # update_timestamp :updated_at, public?: true
  end

  policies do
    policy always() do
      authorize_if always()
    end
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
    belongs_to :enrollment, Zenith.School.Enrollment, allow_nil?: false, public?: true
    belongs_to :language, Zenith.School.Language, allow_nil?: false, public?: true
  end
end
