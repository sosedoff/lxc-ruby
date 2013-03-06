module LXC
  class Status
    attr_reader :state, :pid

    def initialize(state, pid)
      @state = state
      @pid = pid
    end

    def to_hash
      {'state' => state, 'pid' => pid}
    end

    def == (instance)
      instance.pid == pid && instance.state == state
    end
  end
end