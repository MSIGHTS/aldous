require 'aldous/response_action/head'

module Aldous
  module View
    module Headable
      def action(controller)
        ::Aldous::ResponseAction::Head.new(controller)
      end
    end
  end
end
