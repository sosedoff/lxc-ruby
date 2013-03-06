require 'spec_helper'

describe LXC::Status do
  describe '.new' do
    let(:status) { LXC::Status.new('RUNNING', '12345') }

    it 'makes state downcase' do
      status.state.should eq 'running'
    end

    it 'converts given pid into integer' do
      status.pid.should be_an Integer
    end
  end

  describe '#to_hash' do
    let(:status) { LXC::Status.new('RUNNING', '12345') }

    it 'returns a hash representation' do
      result = status.to_hash
      result.should be_a Hash
      result.should include 'state', 'pid'
    end
  end
end