defmodule Data.QueryResume do
  @all_fields_frag_name "ResumeAllFieldsFrag"
  @frag_name "ResumeFrag"
  @frag_name_education "ResumeEducationFrag"
  @frag_name_experience "ExperienceFrag"
  @frag_name_personal_info "PersonalInfoFrag"
  @frag_name_skill "SkillFrag"

  @frag """
    fragment #{@frag_name} on Resume {
      id
      _id
      title
      description
      insertedAt
      updatedAt
    }
  """

  @frag_education """
    fragment #{@frag_name_education} on Education {
      id
      index
      course
      fromDate
      toDate
      school
    }
  """

  @frag_experience """
    fragment #{@frag_name_experience} on Experience {
      id
      companyName
      fromDate
      position
      toDate
      index
    }
  """

  @frag_personal_info """
    fragment #{@frag_name_personal_info} on PersonalInfo {
      id
      address
      dateOfBirth
      email
      firstName
      lastName
      phone
      photo
      profession
    }
  """

  @frag_skill """
    fragment #{@frag_name_skill} on Skill {
      id
      index
      description
    }
  """

  defp all_fields_frag do
    """
      fragment #{@all_fields_frag_name} on Resume {
            ...#{@frag_name}

            education {
              ...#{@frag_name_education}
            }

            experiences {
              ...#{@frag_name_experience}
            }

            personalInfo {
              ...#{@frag_name_personal_info}
            }

            skills {
              ...#{@frag_name_skill}
            }
      }

      #{@frag}
      #{@frag_education}
      #{@frag_experience}
      #{@frag_personal_info}
      #{@frag_skill}
    """
  end

  def create_resume do
    """
      mutation CreateAResume($input:  CreateResumeInput!) {
        createResume(input: $input) {
          resume {
            ...#{@all_fields_frag_name}
          }
        }
      }

      #{all_fields_frag()}
    """
  end

  def list_resumes do
    """
      query ListUserResumes($first: Int!) {
        listResumes(first: $first) {
          pageInfo {
            hasNextPage
            hasPreviousPage
          }

          edges {
            cursor
            node {
              ...#{@frag_name}
            }
          }
        }
      }

      #{@frag}
    """
  end

  def get_resume do
    """
      query GetUserResume($input: GetResumeInput!) {
        getResume(input: $input) {
          ...#{@frag_name}
        }
      }

      #{@frag}
    """
  end

  def update do
    """
      mutation UpdateUserResume($input: UpdateResumeInput!) {
        updateResume(input: $input) {
          resume {
            ...#{@all_fields_frag_name}
          }
        }
      }

      #{all_fields_frag()}
    """
  end

  def delete do
    """
      mutation DeleteAResume($input:  DeleteResumeInput!) {
        deleteResume(input: $input) {
          resume {
            id
            _id
          }
        }
      }
    """
  end

  def clone do
    """
      mutation CloneUserResume($input: CloneResumeInput!) {
        cloneResume(input: $input) {
          resume {
            ...#{@all_fields_frag_name}
          }
        }
      }

      #{all_fields_frag()}
    """
  end
end
