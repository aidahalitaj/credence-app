# frozen_string_literal: true

require_relative 'project'

module Credence
  # Behaviors of the currently logged in account
  class Document
    attr_reader :id, :filename, :relative_path, :description, # basic info
                :content, :project # full details

    def initialize(info)
      @id             = info['id']
      @filename       = info['filename']
      @relative_path  = info['relative_path']
      @description    = info['description']
      @content        = info['content']
      @project        = Project.new(info['project'])
    end
  end
end
