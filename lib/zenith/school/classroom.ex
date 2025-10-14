defmodule Zenith.School.Classroom do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Classroom.
  """

  graphql do
    type :classroom

    queries do
      get :get_classroom, :read
      list :list_classrooms, :read_paginated
    end

    mutations do
      create :create_classroom, :create
      update :update_classroom, :update
      destroy :destroy_classroom, :destroy
    end
  end

  postgres do
    table "classrooms"
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

  policies do
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :capacity, :integer, allow_nil?: false, public?: true
    # create_timestamp :created_at, public?: true
    # update_timestamp :updated_at, public?: true
  end
end
