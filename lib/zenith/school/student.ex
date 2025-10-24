defmodule Zenith.School.Student do
  use Ash.Resource,
    otp_app: :nexus,
    domain: Zenith.School,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource]

  require Ash.Query

  @moduledoc """
  Resource for Student.
  """

  graphql do
    type :student

    queries do
      get :get_student, :read
      list :list_students, :read_paginated
      list :students_not_enrolled_in_class, :not_enrolled_in_class
    end

    mutations do
      create :create_student, :create
      update :update_student, :update
      destroy :destroy_student, :destroy
    end
  end

  postgres do
    table "students"
    repo Zenith.Repo
  end

  actions do
    defaults [:read, create: :*, update: :*]

    read :read_paginated do
      pagination do
        required? false
        keyset? true
        default_limit 10
        countable true
        max_page_size 10
      end
    end

    read :not_enrolled_in_class do
      argument :class_id, :uuid, allow_nil?: false

      prepare fn query, _context ->
        class_id = query.arguments.class_id

        students =
          Zenith.School.Student
          |> Ash.read!()
          |> Ash.load!([:enrollment])

        filtered_students =
          Enum.filter(students, fn student ->
            not Enum.any?(student.enrollment, fn enroll ->
              enroll.class_id == class_id
            end)
          end)

        student_ids = Enum.map(filtered_students, fn student -> student.id end)

        Ash.Query.filter(query, id in ^student_ids)
      end
    end

    destroy :destroy do
      primary? true
      change cascade_destroy(:enrollment)
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
    attribute :email, :string, public?: true, allow_nil?: false
    attribute :phone, :string, public?: true, allow_nil?: false

    attribute :photo_key, :string, public?: true, allow_nil?: true

    # create_timestamp :created_at, public?: true
    # update_timestamp :updated_at, public?: true
  end

  relationships do
    # belongs_to :user, Zenith.School.ResourceNameFather, public?: true
    has_many :enrollment, Zenith.School.Enrollment, public?: true
  end
end
