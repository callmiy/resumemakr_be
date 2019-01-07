defmodule Data.SchemaResume do
  use Absinthe.Schema.Notation

  alias Data.ResolverResume, as: Resolver

  @desc "An object with a rating"
  object :rated do
    field :description, non_null(:string)
    field :level, :integer
  end

  @desc "A resume experience"
  object :resume_experience do
    field :achievements, list_of(:string)
    field :company_name, :string |> non_null()
    field :from_date, :string |> non_null()
    field :position, :string |> non_null()
    field :to_date, :string
  end

  @desc "A Personal Info"
  object :personal_info do
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
    field :course, non_null(:string)
    field :from_date, non_null(:string)
    field :school, non_null(:string)
    field :to_date, :string
    field :achievements, list_of(:string)
  end

  @desc "A Resume"
  object :resume do
    field :id, non_null(:id)
    field :title, non_null(:string)
    field :description, :string
    field :personal_info, :personal_info
    field :languages, list_of(:rated)
    field :additional_skills, list_of(:rated)
    field :experiences, list_of(:resume_experience)
    field :education, list_of(:education)

    field :inserted_at, non_null(:iso_datetime)
    field :updated_at, non_null(:iso_datetime)
  end

  @desc "Variables for creating an object with a rating"
  input_object :rated_input do
    field :description, non_null(:string)
    field :level, :integer
  end

  @desc "Variables for creating resume education"
  input_object :education_input do
    field :course, non_null(:string)
    field :from_date, non_null(:string)
    field :school, non_null(:string)
    field :to_date, :string
    field :achievements, list_of(:string)
  end

  @desc "Variables for creating Personal Info"
  input_object :personal_info_input do
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
  input_object :resume_experience_input do
    field :achievements, list_of(:string)
    field :company_name, :string |> non_null()
    field :from_date, :string |> non_null()
    field :position, :string |> non_null()
    field :to_date, :string
  end

  @desc "Variables for creating Resume"
  input_object :resume_input do
    field :title, non_null(:string)
    field :description, :string
    field :personal_info, :personal_info_input
    field :education, list_of(:education_input)
    field :experiences, list_of(:resume_experience_input)
    field :languages, list_of(:rated_input)
    field :additional_skills, list_of(:rated_input)
  end

  @desc "Variables for getting a Resume"
  input_object :get_resume do
    field :title, non_null(:id)
  end

  @desc "Mutations allowed on Resume object"
  object :resume_mutation do
    @doc "Create a resume"
    field :resume, :resume do
      arg(:resume, non_null(:resume_input))

      resolve(&Resolver.create/3)
    end
  end

  # @desc "Queries allowed on Resume object"
  # object :resume_query do
  #   @desc "query a resume "
  #   field :resume, :resume do
  #     arg(:resume, non_null(:get_resume))
  #     resolve(&Resolver.field/3)
  #   end
  # end
end
