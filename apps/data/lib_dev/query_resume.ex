defmodule Data.QueryResume do
  @frag_name "ResumeAllFieldsFrag"
  @frag_name_rated "RatedFrag"
  @frag_name_education "ResumeeducationFrag"
  @frag_name_experience "ResumeExperienceFrag"
  @frag_name_personal_info "PersonalInfoFrag"

  @frag """
    fragment #{@frag_name} on Resume {
      id
      title
      description
      insertedAt
      updatedAt
    }
  """

  @frag_rated """
    fragment #{@frag_name_rated} on Rated {
      description
      level
    }
  """

  @frag_education """
    fragment #{@frag_name_education} on Education {
      course
      fromDate
      toDate
      school
      achievements
    }
  """

  @frag_experience """
    fragment #{@frag_name_experience} on ResumeExperience {
      achievements
      companyName
      fromDate
      position
      toDate
    }
  """

  @frag_personal_info """
    fragment #{@frag_name_personal_info} on PersonalInfo {
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

  def create_resume do
    """
      mutation CreateAResume($resume:  ResumeInput!) {
        resume(resume: $resume) {
          ...#{@frag_name}

          additionalSkills {
            ...#{@frag_name_rated}
          }

          languages {
            ...#{@frag_name_rated}
          }

          education {
            ...#{@frag_name_education}
          }

          experiences {
            ...#{@frag_name_experience}
          }

          personalInfo {
            ...#{@frag_name_personal_info}
          }
        }
      }

      #{@frag}
      #{@frag_rated}
      #{@frag_education}
      #{@frag_experience}
      #{@frag_personal_info}
    """
  end
end
