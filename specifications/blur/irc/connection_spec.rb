# encoding: utf-8

require_relative '../../spec_helper'

LongSession = <<-eos
PING some.server\r
:nick!user@host PRIVMSG #some_channel :hello world\r
:nick!user@host PRIVMSG #some_channel :hello world\r
:nick!user@host PRIVMSG #some_channel :hello world\r
:nick!user@host PRIVMSG #some_channel :hello world\r
:nick!user@host PRIVMSG #some_channel :hello world\r
:nick2!user2@host2 PRIVMSG &some_channel hello\r
:nick2!user2@host2 PRIVMSG &some_channel hello\r
:nick2!user2@host2 PRIVMSG &some_channel hello\r
:nick2!user2@host2 PRIVMSG &some_channel hello\r
:nick2!user2@host2 PRIVMSG &some_channel hello\r
:nick2!user2@host2 JOIN #some_other_channel\r
eos

OneLineSession = "PING some.server"

describe Blur::IRC::Connection do
  let(:options) { { ssl: false } }

  subject do
    described_class.new 1, options
  end

  describe '#receive_data' do
    it 'should split messages into lines' do
      expect(subject).to receive(:receive_line).once.with("PING some.server\r\n")

      subject.receive_data "PING some.server\r\n"
    end

    it 'should read multiple lines' do
      expect(subject).to receive(:receive_line).twice

      subject.receive_data "PING some.server\r\nPING some.server\r\n"
    end

    it 'should slice the buffer' do
      initial_data = LongSession
      incomplete_data = 'some incomplete data with no line feed' 

      subject.buffer << initial_data

      expect(subject.buffer.bytesize).to eq initial_data.bytesize
      subject.receive_data incomplete_data

      expect(subject.buffer).to eq incomplete_data
    end
  end

  describe '#receive_line' do
    it 'should parse the line using Command.parse' do
      expect(Blur::IRC::Command).to receive :parse

      subject.receive_line OneLineSession
    end

    it 'should call appropriate handler for the command'
  end
end
