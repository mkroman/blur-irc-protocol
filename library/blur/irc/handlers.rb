# encoding: utf-8

module Blur
  module IRC
    # Isolated module for protocol-specific parsing and stateless handling.
    module Handlers
      Methods = {
        'JOIN' => :handle_join,
        'PING' => :handle_ping,
        'ERROR' => :handle_error
      }.freeze

      def self.handle_join connection, command
        connection.delegate :join, command.prefix
      end

      # PING <server1> [<server2>]
      def self.handle_ping connection, command
        connection.server_ping :ping, command[0]
      end

      def self.handle_error connection, command

      end
    end
  end
end
