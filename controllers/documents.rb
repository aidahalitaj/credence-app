# frozen_string_literal: true

require 'roda'

module Credence
  # Web controller for Credence API
  class App < Roda
    route('documents') do |routing|
      routing.on do
        # GET /documents/
        routing.get(String) do |doc_id|
          if @current_user.logged_in?
            doc_info = GetDocument.new(App.config)
                                  .call(@current_user, doc_id)
            # puts "DOC: #{doc_info}"
            document = Document.new(doc_info)

            view :document, locals: {
              current_user: @current_user, document: document
            }
          else
            routing.redirect '/auth/login'
          end
        end
      end
    end
  end
end
