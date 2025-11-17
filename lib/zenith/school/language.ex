defmodule Zenith.School.Language do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  @moduledoc """
  Resource for Language.
  """

  graphql do
    type :language

    queries do
      get :get_language, :read
      list :list_languages, :read_paginated
    end

    mutations do
      create :create_language, :create
      update :update_language, :update
    end
  end

  postgres do
    table "languages"
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

    attribute :name, :string, public?: true, allow_nil?: false
    attribute :description, :string, public?: true, allow_nil?: true

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    # belongs_to :user, Zenith.School.ResourceNameFather, public?: true
  end
end
