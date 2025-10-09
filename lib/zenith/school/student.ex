defmodule Zenith.School.Student do
  use Ash.Resource,
  otp_app: :nexus,
  domain: Zenith.School,
  data_layer: AshPostgres.DataLayer,
  authorizers: [Ash.Policy.Authorizer],
  extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Student.
  """

  graphql do
    type :student

    queries do
      get :get_student, :read
      list :list_students, :read_paginated
    end

    mutations do
      create :create_student, :create
      update :update_student, :update
    end
  end

  postgres do
    table "students"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :email, :string, public?: true, allow_nil?: false
    attribute :phone, :string, public?: true, allow_nil?: false

    # create_timestamp :created_at, public?: true
    # update_timestamp :updated_at, public?: true
  end

  policies do
    policy always() do
      authorize_if always()
    end
  end

  actions do
    defaults [:read, :destroy, update: :*]

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

      argument :enrollments, :map, allow_nil?: false

      change manage_relationship(:enrollments, :enrollment, type: :create)
    end
  end

  relationships do
    # belongs_to :user, Zenith.School.ResourceNameFather, public?: true
    has_many :enrollment, Zenith.School.Enrollment, public?: true
  end
end
