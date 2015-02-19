# encoding: utf-8

require 'strscan'

module Blur
  module IRC
    # +Connection+ class.
    #
    # Use this class when connection to an IRC server.
    class Connection < EM::Connection
      # IRC messages are always lines of characters terminated with a CR-LF
      # pair.
      Delimiter = /\r\n/.freeze

      # @!attribute [r] buffer
      #   @return [String] the receiving buffer.
      attr_reader :buffer

      # Instantiate a new {Connection}.
      #
      # @param options [Hash] connection options.
      # @option options [Boolean] :ssl (false) establish ssl/tls connection.
      def initialize options
        @options = options
        super
      end

      # Called when the connection is intialized.
      def post_init
        @buffer = String.new
        @scanner = StringScanner.new @buffer

      end

      # Called when the connection is initially established.
      def connection_completed
        if @options[:ssl]
          start_tls ssl_options
        end
      end

      # Called when data is being received.
      #
      # Once data has been received, buffer the received data, split it into
      # lines and pass each line to {#receive_line}.
      def receive_data data
        @buffer << data

        while line = @scanner.scan_until(Delimiter)
          receive_line line
        end

        if @scanner.pos > 0
          @buffer.slice! 0, @scanner.pos
          @scanner.reset
        end
      end

      # Called when a full line has been received.
      #
      # Once a line has been received, parse it as a command structure and
      # delegate it to the {#receive_command} method.
      def receive_line line
        command = Command.parse line
        receive_command command
      end

      # Called when a command has been received.
      #
      # This is up to the user of this protocol to implement.
      #
      # @see Command
      def receive_command command; end

    protected

      def ssl_options
        @ssl_options ||= @options[:ssl] == true ? {} : @options[:ssl] || {}
      end
    end
  end
end
