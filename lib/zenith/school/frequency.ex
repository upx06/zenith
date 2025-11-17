defmodule Zenith.School.Frequency do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Frequency.
  """

  graphql do
    type :frequency

    queries do
      get :get_frequency, :read
      list :list_frequencies, :read_paginated
    end

    mutations do
      create :create_frequency, :create
      update :update_frequency, :update
    end
  end

  postgres do
    table "frequencies"
    repo Zenith.Repo

    references do
      reference :lesson,
        on_delete: :delete,
        name: "frequencies_lesson_id_fkey"
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

  policies do
    policy always() do
      authorize_if always()
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :attendance, :boolean, public?: true, allow_nil?: false

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :lesson, Zenith.School.Lesson, public?: true
    belongs_to :enrollment, Zenith.School.Enrollment, public?: true
  end
end
