require 'require_me'
  
def rpc val, &blk
  d = EventMachine::DefaultDeferrable.new
  d.callback { 
    blk.call(val)
  }
  
  EventMachine.add_timer(0.1) {
    d.succeed(val)
  }
  
end

EventMachine.run {
  start_time = Time.now

  rpc(1) do |rpc_1|
    rpc(2) do |rpc_2|
      puts rpc_1 + rpc_2
    end
  end

  # just quit after half a sec
  EventMachine.add_timer(0.5) {
    puts "Total Runtime: #{Time.now - start_time}"
    EventMachine.stop
  }
}