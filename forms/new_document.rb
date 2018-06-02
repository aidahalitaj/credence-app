# frozen_string_literal: true

require 'dry-validation'

module Credence
  module Form
    NewDocument = Dry::Validation.Params do
      FILENAME_REGEX = %r{^((?![&\/\\\{\}\|\t]).)*$}
      PATH_REGEX = /^((?![&\{\}\|\t]).)*$/

      configure do
        config.messages_file = File.join(__dir__, 'errors/new_document.yml')
      end

      required(:filename).filled(max_size?: 256, format?: FILENAME_REGEX)
      required(:relative_path).maybe(format?: PATH_REGEX)
      required(:description).maybe
      required(:content).filled
    end
  end
end
