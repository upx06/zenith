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
      list :list_enrollments, :read_paginated
      list :list_specific_enrollments, :list_specific_enrollments
    end

    mutations do
      create :create_enrollment, :create
      update :update_enrollment, :update
      destroy :destroy_enrollment, :destroy
    end
  end

  postgres do
    table "enrollments"
    repo Zenith.Repo

    references do
      reference :student,
        on_delete: :delete,
        name: "enrollments_student_id_fkey"
    end
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

    read :list_specific_enrollments do
      argument :class_id, :uuid, allow_nil?: false
      filter expr(class_id == ^arg(:class_id))
    end
  end

  relationships do
    belongs_to :student, Zenith.School.Student, allow_nil?: false, public?: true
    belongs_to :class, Zenith.School.Class, allow_nil?: true, public?: true

    has_many :scores, Zenith.School.Score, public?: true
  end
end
