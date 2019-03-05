require_relative 'helpers/message_handler'

module Sequent
  module Core
    class Workflow
      include Helpers::MessageHandler

      def execute_commands(*commands)
        Sequent.configuration.command_service.execute_commands(*commands)
      end

      def after_commit(&block)
        Sequent.configuration.transaction_provider.after_commit &block
      end
    end
  end
end
