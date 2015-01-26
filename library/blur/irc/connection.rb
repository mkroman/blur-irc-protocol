# encoding: utf-8

require 'strscan'

module Blur
  module IRC
    # +Connection+ class.
    #
    # Use this class when connection to an IRC server.
    class Connection < EM::Connection
      Delimiter = /\r\n/.freeze

      attr_reader :buffer

      def initialize options
        @options = options

        super
      end

      def post_init
        @buffer = String.new
        @scanner = StringScanner.new @buffer

        if @options[:ssl] 
          start_tls
        end
      end

      # Data is being received. Buffer it and parse it.
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

      # Line has been received. Parse it.
      def receive_line line
        command = Command.parse line


      end
    end
  end
end
