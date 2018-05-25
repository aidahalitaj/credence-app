# frozen_string_literal: true

require_relative 'project'

module Credence
  # Behaviors of the currently logged in account
  class Project
    attr_reader :id, :name, :repo_url

    def initialize(proj_info)
      @id = proj_info['id']
      @name = proj_info['name']
      @repo_url = proj_info['repo_url']
    end
  end
end
