# frozen_string_literal: true

require_relative 'document'
require_relative 'user'
require 'ostruct'

module Credence
  # Behaviors of the currently logged in account
  class Project
    attr_reader :id, :name, :repo_url, # basic info
                :owner, :collaborators, :documents, :policies # full details

    def initialize(info)
      @id = info['id']
      @name = info['name']
      @repo_url = info['repo_url']
      @owner = User.new(info['owner'])
      @collaborators = process_collaborators(info['collaborators'])
      @documents = process_documents(info['documents'])
      @policies = OpenStruct.new(info['policies'])
    end

    private

    def process_documents(documents_info)
      return nil unless documents_info
      documents_info.map { |doc_info| Document.new(doc_info) }
    end

    def process_collaborators(documents_info)
      return nil unless documents_info
      documents_info.map { |account_info| User.new(account_info) }
    end
  end
end
