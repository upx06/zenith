defmodule Zenith.School.Teacher do
  use Ash.Resource,
  otp_app: :nexus,
  domain: Zenith.School,
  authorizers: [Ash.Policy.Authorizer],
  data_layer: AshPostgres.DataLayer,
  extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Teacher.
  """

  graphql do
    type :teacher

    queries do
      get :get_teacher, :read
      list :list_teachers, :read_paginated
    end

    mutations do
      create :create_teacher, :create
      update :update_teacher, :update
      destroy :destroy_teacher, :destroy
    end
  end

  postgres do
    table "teachers"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :email, :string, allow_nil?: false, public?: true
    attribute :phone, :string, allow_nil?: false, public?: true

    attribute :photo_key, :string, allow_nil?: true, public?: true

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
    has_many :lessons, Zenith.School.Lesson, public?: true
  end
end
