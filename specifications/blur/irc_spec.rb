# encoding: utf-8

require_relative '../spec_helper'

describe Blur::IRC do
  it 'should have a version constant' do
    expect(subject.const_defined?(:Version)).to eq true
  end

  it 'should have a version class method' do
    expect(subject).to respond_to :version
    expect(subject.version).to eq subject::Version
  end
end
