require 'rubygems'
require 'eventmachine'

case RUBY_VERSION 
when "1.9.1" # stock ruby 1.9.1
  require 'fiber'
when "1.8.7" # assume tmm1's patched 1.8.7 with fibers
  require 'fiber'
when "1.8.6" # some other poor ruby
  require '~/Source/Ruby/fiber18/lib/fiber18'
end

def rpc val
  f = Fiber.current

  d = EventMachine::DefaultDeferrable.new
  d.callback {
    f.resume(val)
  }    
  
  EventMachine.add_timer(0.1) {
    d.succeed
  }

  return Fiber.yield
end  
  

EventMachine.run {
  start_time = Time.now
  
  # Note, we've gotta do all the meaty stuff in a fiber I think...
  # by "meaty" I mean, everything that we want to ensure happens *synchronously*
  Fiber.new { 
    start = Time.now
    result = rpc(1) + rpc(2)
    puts "Ran for: #{Time.now - start}"
    puts result
  }.resume


  # just quit after half a sec
  EventMachine.add_timer(0.5) {
    puts "Total Runtime: #{Time.now - start_time}"
    EventMachine.stop
  }
  
  
}