# frozen_string_literal: true

require 'http'

# Returns all projects belonging to an account
class GetAllProjects
  def initialize(config)
    @config = config
  end

  def call(user)
    response = HTTP.auth("Bearer #{user.auth_token}")
                   .get("#{@config.API_URL}/projects")
    response.code == 200 ? response.parse : nil
  end
end
