require_relative 'helpers/message_handler'

module Sequent
  module Core
    class Workflow
      include Helpers::MessageHandler

      def self.on(*message_classes, &block)
        decorated_block = ->(event) do
          begin
            old_event = Thread.current[:handling_event]
            Thread.current[:handling_event] = event
            self.instance_exec(event, &block)
          ensure
            Thread.current[:handling_event] = old_event
          end
        end
        super(*message_classes, &decorated_block)
      end

      def current_event
        Thread.current[:handling_event]
      end

      def execute_commands(*commands)
        commands.each do |command|
          if command.respond_to?(:event_aggregate_id) && command.event_aggregate_id.blank?
            command.event_aggregate_id = current_event.aggregate_id
            command.event_sequence_number = current_event.sequence_number
          end
        end

        Sequent.configuration.command_service.execute_commands(*commands)
      end
    end
  end
end
