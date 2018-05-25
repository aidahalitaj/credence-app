# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class App < Roda
    route('projects') do |routing|
      routing.on do
        # GET /projects/
        routing.get do
          if @current_user.logged_in?
            project_list = GetAllProjects.new(App.config).call(@current_user)

            projects = Projects.new(project_list)

            view :projects_all,
                 locals: { current_user: @current_user, projects: projects }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end