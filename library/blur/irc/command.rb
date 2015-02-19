# encoding: utf-8

module Blur
  module IRC
    # The +Command+ class is used for encapsulating the command-lines.
    #
    # Blur is using regular-expression for parsing, this is to be replaced
    # with a more native way of parsing, making it much, much easier on the
    # processor.
    class Command
      # @return [Symbol, Fixnum] the command name.
      # @example
      #   332 or :quit
      attr_accessor :name
      # @return [Array] a list of parameters.
      attr_accessor :params
      # @return [String] a hostname or a hostmask.
      attr_accessor :prefix

      Host = "\\S+"
      # '-' | '[' | ']' | '\' | '`' | '^' | '{' | '}'
      Special = "\\-\\[\\]\\\\`^\\{\\}"

      Letter = "a-zA-Z"

      Number = "0-9"

      NonWhite = "[^\\x20\\x00\\x0d\\x0a]"

      # <letter> { <letter> | <number> | <special> }
      Nick = "[#{Letter}][#{Letter}#{Number}#{Special}]*"

      # <nonwhite> { <nonwhite> }
      User = "\\S+"

      # <host>
      ServerName = "\\S+"

      Space = "\\x20"

      # <servername> | <nick> [ '!' <user> ] [ '@' <host> ]
      Prefix = "#{ServerName}|#{Nick}(?:!#{User})?(?:@#{Host})?"

      # <letter> { <letter> } | <number> <number> <number>
      Command = "[a-zA-Z]+|[0-9]{3}"
      # <Any, possibly *empty*, sequence of octets not including 
      # NUL or CR or LF
      Trailing = "[^\\x00\\x0a\\x0d]"

      # <Any *non-empty* sequence of octets not including SPACE
      # or NUL or CR or LF, the first of which may not be ':'>
      Middle = "(?:[^:][^\\x20\\x00\\x0a\\x0d]*)"
 #     Prefix = /(?::(?<prefix>\S+) )?/
      # <SPACE> [ ':' <trailing> | <middle> <params> ]
      Params = "(#{Trailing}|#{Middle}+)"

      LinePattern = "
        ^(?::(#{Prefix})#{Space}+)?   (?# 1: prefix)
        (#{Command})                 (?# 2: command)
        \\x20*
        (?:([^:][^\\x20\\x00\\x0a\\x0d]*)\\x20?)* (?# 3: params)
        (?::([^\\x00\\x0a\\x0d]*))?   (?# 4: trailing)"

      LinePattern2 = "
        ^(?::(?<prefix>#{Prefix})#{Space})?   (?# 1: prefix)
        (?<command>#{Command})            (?# 2: command)
        \\x20*
        (?:
          (?::([^\\x00\\x0a\\x0d]*)) 
        |
          (?:[^:][^\\x20\\x00\\x0a\\x0d]*)
        )
      "

      # The arbitrary regex pattern.
      Pattern = /^(?:[:@]([^\s]+) )?([^\s]+)(?: ((?:[^:\s][^\s]* ?)*))?(?: ?:(.*))?$/
      HostMask = /^(#{Nick})!(\S+)@(\S+)$/
      
      # Parse a line and encapsulate it as a Command.
      #
      # @return [Command] the parsed command.
      # @example
      #   Command.parse "ChanServ!ChanServ@services.uplink.io MODE #uplink +v mk"
      #   # => #<Blur::Network::Command … >
      def self.parse line
        match = line.strip.match Pattern
        prefix, name, args, extra = match.captures
        params = extra ? args.split << extra : args.split

        new(name, params).tap do |this|
          this.prefix = prefix
        end
      end

      # Get a parameter by its +index+.
      def [] index; @params[index] end

      # Instantiate a command.
      #
      # @see Command.parse
      def initialize name, params = []
        @name, @params = name, params
      end

      # Get the sender of the command.
      #
      # @note the return value is a string if it's a hostname, and an openstruct
      #   with the attributes #nickname, #username and #hostname if it's a
      #   hostmask.
      #
      # @return [String, OpenStruct] the sender.
      def sender
        return @sender if @sender

        if prefix =~ HostMask
          @sender = OpenStruct.new nickname: $1, username: $2, hostname: $3
        else
          @sender = prefix
        end
      end

      # Convert it to an IRC-compliant line.
      #
      # @return [String] the command line.
      def to_s
        String.new.tap do |line|
          line << "#{prefix} " if prefix
          line << name.to_s

          params.each_with_index do |param, index|
            line << ' '
            line << ?: if index == params.length - 1 and param =~ /[ :]/
            line << param.to_s
          end
        end
      end
    end
  end
end
