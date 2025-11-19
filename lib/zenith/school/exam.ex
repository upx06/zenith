defmodule Zenith.School.Exam do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Test.
  """

  graphql do
    type :exam

    queries do
      get :get_exam, :read
      list :list_exams, :read_paginated
    end

    mutations do
      create :create_exam, :create
      update :update_exam, :update
      update :update_scores, :update_scores
      destroy :destroy_exam, :destroy
    end
  end

  postgres do
    table "exams"
    repo Zenith.Repo
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
      argument :topics, {:array, :map}, allow_nil?: false
      change manage_relationship(:topics, type: :create)
    end

    update :update_scores do
      accept [:*]
      require_atomic? false
      argument :scores, {:array, :map}, allow_nil?: true

      change manage_relationship(:scores,
               type: :direct_control,
               use_identities: [:score_identity]
             )
    end
  end

  attributes do
    uuid_v7_primary_key :id
    attribute :name, :string, public?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :class, Zenith.School.Class, public?: true, allow_nil?: true
    belongs_to :enrollment, Zenith.School.Enrollment, public?: true, allow_nil?: true
    belongs_to :teacher, Zenith.School.Teacher, public?: true, allow_nil?: false

    has_many :topics, Zenith.School.Topic, public?: true
    has_many :scores, Zenith.School.Score, public?: true
  end
end
