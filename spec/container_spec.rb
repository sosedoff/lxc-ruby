require 'spec_helper'

describe LXC::Container do
  it 'has proper attributes' do
    c = LXC::Container.new('vm0')
    c.should respond_to(:name)
    c.should respond_to(:state)
    c.should respond_to(:pid)
  end
end