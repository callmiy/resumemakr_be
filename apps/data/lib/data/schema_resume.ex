defmodule Data.SchemaResume do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.ResolverResume, as: Resolver

  @desc "An object with a rating"
  object :rated do
    field :id, non_null(:id)
    field :description, non_null(:string)
    field :level, :string
  end

  @desc "A resume experience"
  object :resume_experience do
    field :id, non_null(:id)
    field :achievements, list_of(:string)
    field :company_name, :string |> non_null()
    field :from_date, :string |> non_null()
    field :position, :string |> non_null()
    field :to_date, :string
  end

  @desc "A Personal Info"
  object :personal_info do
    field :id, non_null(:id)
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :address, :string
    field :email, :string
    field :phone, :string
    field :profession, :string
    field :date_of_birth, :date
    field :photo, :string
  end

  @desc "A resume education"
  object :education do
    field :id, non_null(:id)
    field :course, non_null(:string)
    field :from_date, non_null(:string)
    field :school, non_null(:string)
    field :to_date, :string
    field :achievements, list_of(:string)
  end

  @desc "A resume skill"
  object :skill do
    field :id, non_null(:id)
    field :description, non_null(:string)
    field :achievements, list_of(:string)
  end

  @desc "A Resume"
  node object(:resume) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :title, non_null(:string)
    field :description, :string
    field :personal_info, :personal_info
    field :languages, list_of(:rated)
    field :additional_skills, list_of(:rated)
    field :experiences, list_of(:resume_experience)
    field :education, list_of(:education)
    field :skills, list_of(:skill)

    field :inserted_at, non_null(:iso_datetime)
    field :updated_at, non_null(:iso_datetime)
  end

  @desc "Variables for creating an object with a rating"
  input_object :rated_input do
    field :id, :id
    field :description, non_null(:string)
    field :level, :string
  end

  @desc "Variables for creating resume education"
  input_object :education_input do
    field :id, :id
    field :course, non_null(:string)
    field :from_date, non_null(:string)
    field :school, non_null(:string)
    field :to_date, :string
    field :achievements, list_of(:string)
  end

  @desc "Variables for creating Personal Info"
  input_object :personal_info_input do
    field :id, :id
    field :first_name, non_null(:string)
    field :last_name, non_null(:string)
    field :address, non_null(:string)
    field :email, non_null(:string)
    field :phone, non_null(:string)
    field :profession, non_null(:string)
    field :date_of_birth, :date
    field :photo, :string
  end

  @desc "Variables for creating resume experience"
  input_object :create_experience_input do
    field :id, :id
    field :achievements, list_of(:string)
    field :company_name, :string |> non_null()
    field :from_date, :string |> non_null()
    field :position, :string |> non_null()
    field :to_date, :string
  end

  @desc "A resume skill"
  input_object :create_skill_input do
    field :id, :id
    field :description, non_null(:string)
    field :achievements, list_of(:string)
  end

  @desc "Variables for getting a Resume"
  input_object :get_resume do
    field :title, non_null(:id)
  end

  @desc "Mutations allowed on Resume object"
  object :resume_mutation do
    @doc "Create a resume"
    payload field :create_resume do
      input do
        field :title, non_null(:string)
        field :description, :string
        field :personal_info, :personal_info_input
        field :education, list_of(:education_input)
        field :experiences, list_of(:create_experience_input)
        field :languages, list_of(:rated_input)
        field :additional_skills, list_of(:rated_input)
        field :skills, list_of(:create_skill_input)
      end

      output do
        field :resume, :resume
      end

      resolve(&Resolver.create/3)
    end

    @doc "Update a resume"
    payload field :update_resume do
      input do
        field :id, :id |> non_null()
        field :title, :string
        field :description, :string
        field :personal_info, :personal_info_input
        field :education, list_of(:education_input)
        field :experiences, list_of(:create_experience_input)
        field :languages, list_of(:rated_input)
        field :additional_skills, list_of(:rated_input)
        field :skills, list_of(:create_skill_input)
      end

      output do
        field :resume, :resume
      end

      parsing_node_ids(&Resolver.update/2, id: :resume) |> resolve()
    end

    @doc "Delete a resume"
    payload field :delete_resume do
      input do
        field :id, :id |> non_null()
      end

      output do
        field :resume, :resume
      end

      parsing_node_ids(&Resolver.delete/2, id: :resume) |> resolve()
    end
  end

  @desc "Queries allowed on Resume object"
  object :resume_query do
    @desc "query a resume "
    connection field :resumes, node_type: :resume do
      resolve(&Resolver.resumes/2)
    end
  end

  connection(node_type: :resume)
end
