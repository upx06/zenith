defmodule Zenith.School.Class do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Class.
  """

  graphql do
    type :class

    queries do
      get :get_class, :read
      list :list_classes, :read_paginated
    end

    mutations do
      create :create_class, :create
      update :update_class, :update
    end
  end

  postgres do
    table "classes"
    repo Zenith.Repo
  end

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    read :read_paginated do
      pagination do
        required? false
        keyset? true
        default_limit 9
        countable true
        max_page_size 9
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

    attribute :level, :atom do
      allow_nil? false
      public? true
      constraints one_of: [:A1, :A2, :B1, :B2, :C1, :C2]
    end

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :language, Zenith.School.Language do
      public? true
      allow_nil? false
    end

    has_many :enrollments, Zenith.School.Enrollment, public?: true
    has_many :lessons, Zenith.School.Lesson, public?: true
  end
end
