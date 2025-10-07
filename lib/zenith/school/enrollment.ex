defmodule Zenith.School.Enrollment do
  use Ash.Resource,
  otp_app: :nexus,
  domain: Zenith.School,
  authorizers: [Ash.Policy.Authorizer],
  data_layer: AshPostgres.DataLayer,
  extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Enrollment.
  """

  graphql do
    type :enrollment

    queries do
      get :get_enrollment, :read
      list :list_enrollment, :read_paginated
    end

    mutations do
      create :create_enrollment, :create
      update :update_enrollment, :update
    end
  end

  postgres do
    table "enrollments"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    # create_timestamp :created_at, public?: true
    # update_timestamp :updated_at, public?: true
  end

  policies do
    policy always() do
      authorize_if actor_present()
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
    belongs_to :student, Zenith.School.Student, allow_nil?: false, public?: true
    belongs_to :class, Zenith.School.Class, allow_nil?: true, public?: true
  end
end
