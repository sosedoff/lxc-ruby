require 'spec_helper'

describe LXC::Status do
  describe '.new' do
    let(:status) { LXC::Status.new('RUNNING', '12345') }

    it 'makes state downcase' do
      expect(status.state).to eq 'running'
    end

    it 'converts given pid into integer' do
      expect(status.pid).to be_an Integer
    end
  end

  describe '#to_hash' do
    let(:status) { LXC::Status.new('RUNNING', '12345') }

    it 'returns a hash representation' do
      result = status.to_hash
      expect(result).to be_a Hash
      expect(result).to include 'state', 'pid'
    end
  end

  describe '#to_s' do
    let(:status) { LXC::Status.new('RUNNING', '12345') }

    it 'returns a string representation' do
      expect(status.to_s).to eq 'state=running pid=12345'
    end
  end
end
