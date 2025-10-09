defmodule Zenith.School.Lesson do
  use Ash.Resource,
  otp_app: :nexus,
  domain: Zenith.School,
  authorizers: [Ash.Policy.Authorizer],
  data_layer: AshPostgres.DataLayer,
  extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Lesson.
  """

  graphql do
    type :lesson

    queries do
      get :get_lesson, :read
      list :list_lessons, :read_paginated
    end

    mutations do
      create :create_lesson, :create
      update :update_lesson, :update
    end
  end

  postgres do
    table "lessons"
    repo Zenith.Repo
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :datetime, :utc_datetime, allow_nil?: false, public?: true
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
    belongs_to :teacher, Zenith.School.Teacher, public?: true, allow_nil?: false
    belongs_to :class, Zenith.School.Class, public?: true, allow_nil?: false
    belongs_to :classroom, Zenith.School.Classroom, public?: true, allow_nil?: false
  end
end
