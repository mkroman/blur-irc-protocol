# encoding: utf-8

module Blur
  module IRC
    # Isolated module for protocol-specific parsing and handling.
    module Handlers
      Methods = {
        'JOIN' => :handle_join,
        'PING' => :handle_ping
      }.freeze

      def self.handle_join connection, command

        connection.delegate :join, command.prefix
      end

      def self.handle_ping connection, command
        connection.delegate :ping, command[0]
      end
    end
  end
end
