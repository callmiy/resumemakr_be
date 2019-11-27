defmodule Data.SchemaResume do
  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias Data.ResolverResume, as: Resolver

  @desc "An object with a rating"
  object :rated do
    field :id, non_null(:id)
    field :description, :string
    field :level, :string
    field :index, :integer |> non_null()
  end

  @desc "A resume experience"
  object :experience do
    field :id, non_null(:id)
    field :achievements, list_of(:string)
    field :company_name, :string
    field :from_date, :string
    field :position, :string
    field :to_date, :string
    field :index, :integer |> non_null()
  end

  @desc "A Personal Info"
  object :personal_info do
    field :id, non_null(:id)
    field :first_name, :string
    field :last_name, :string
    field :address, :string
    field :email, :string
    field :phone, :string
    field :profession, :string
    field :date_of_birth, :string
    field :photo, :string
  end

  @desc "A resume education"
  object :education do
    field :id, non_null(:id)
    field :course, :string
    field :from_date, :string
    field :school, :string
    field :to_date, :string
    field :achievements, list_of(:string)
    field :index, :integer |> non_null()
  end

  @desc "A resume skill"
  object :skill do
    field :id, non_null(:id)
    field :description, :string
    field :achievements, list_of(:string)
    field :index, :integer |> non_null()
  end

  @desc "A Resume"
  node object(:resume) do
    field :_id, non_null(:id), resolve: fn %{id: id}, _, _ -> {:ok, id} end
    field :title, non_null(:string)
    field :description, :string
    field :languages, list_of(:rated)
    field :additional_skills, list_of(:rated)
    field :hobbies, list_of(:string)

    field :personal_info, :personal_info do
      resolve(Resolver.get_assoc(:personal_info))
    end

    field :experiences, list_of(:experience) do
      resolve(Resolver.get_assoc(:experiences))
    end

    field :education, list_of(:education) do
      resolve(Resolver.get_assoc(:education))
    end

    field :skills, list_of(:skill) do
      resolve(Resolver.get_assoc(:skills))
    end

    field :inserted_at, non_null(:iso_datetime)
    field :updated_at, non_null(:iso_datetime)
  end

  object :resume_success do
    field :resume, :resume
  end

  object :update_resume_error_fields do
    field :title, :string
    field :description, :string
    field :error, :string
  end

  object :update_resume_error do
    field :error, :update_resume_error_fields
  end

  union :update_resume_minimal_payload do
    types([:resume_success, :update_resume_error])
    resolve_type(&Resolver.resolve_update_resume_payload/2)
  end

  ###################### START INPUT OBJECTS ###############################

  @desc "Variables for creating an object with a rating"
  input_object :rated_input do
    field :id, :id
    field :description, :string
    field :level, :string
    field :index, :integer |> non_null()
  end

  @desc "Variables for creating resume education"
  input_object :education_input do
    field :id, :id
    field :course, :string
    field :from_date, :string
    field :school, :string
    field :to_date, :string
    field :achievements, list_of(:string)
    field :index, :integer |> non_null()
  end

  @desc "Variables for creating Personal Info"
  input_object :personal_info_input do
    field :id, :id
    field :first_name, :string
    field :last_name, :string
    field :address, :string
    field :email, :string
    field :phone, :string
    field :profession, :string
    field :date_of_birth, :string

    field :photo, :file_upload do
    end
  end

  @desc "Variables for creating resume experience"
  input_object :create_experience_input do
    field :id, :id
    field :achievements, list_of(:string)
    field :company_name, :string
    field :from_date, :string
    field :position, :string
    field :to_date, :string
    field :index, :integer |> non_null()
  end

  @desc "A resume skill"
  input_object :create_skill_input do
    field :id, :id
    field :description, :string
    field :achievements, list_of(:string)
    field :index, :integer |> non_null()
  end

  @desc "Variables for getting a Resume"
  input_object :get_resume_input do
    field :id, :id
    field :title, :string
  end

  @desc ~S"""
    variables for updating minimal attributes of resume.
  """
  input_object :update_resume_minimal_input do
    field :id, non_null(:id)
    field :title, :string
    field :description, :string
  end

  ###################### END INPUT OBJECTS ###############################

  ###################### MUTATIONS ###############################

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
        field :hobbies, list_of(:string)
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
        field :hobbies, list_of(:string)
      end

      output do
        field :resume, :resume
      end

      parsing_node_ids(&Resolver.update/2, id: :resume) |> resolve()
    end

    @desc "Delete a resume"
    payload field :delete_resume do
      input do
        field :id, :id |> non_null()
      end

      output do
        field :resume, :resume
      end

      parsing_node_ids(&Resolver.delete/2, id: :resume) |> resolve()
    end

    @desc "Create a resume by copying data from an existing resume"
    payload field :clone_resume do
      input do
        field :id, :id |> non_null()
        field :title, :string
        field :description, :string
      end

      output do
        field :resume, :resume
      end

      parsing_node_ids(&Resolver.clone/2, id: :resume) |> resolve()
    end

    @desc ~S"""
      mutation - minimally update a resume
    """
    field :update_resume_minimal, :update_resume_minimal_payload do
      arg(:input, non_null(:update_resume_minimal_input))
      resolve(&Resolver.update_resume_minimal/2)
    end
  end

  ###################### END MUTATIONS ###############################

  @desc "Queries allowed on Resume object"
  object :resume_query do
    @desc "query a resume "
    connection field :list_resumes, node_type: :resume do
      resolve(&Resolver.resumes/2)
    end

    @desc "Get a resume"
    field :get_resume, :resume do
      arg(:input, :get_resume_input |> non_null())

      resolve(&Resolver.get_resume/2)
    end
  end

  connection(node_type: :resume)
end
