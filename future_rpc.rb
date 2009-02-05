require 'require_me'

# Shamelessly stolen and (poorly) adapted from mentalguy's lazy.rb lib
class Future
  alias __class__ class
  alias __send__ send
  instance_methods.each { |m| undef_method m unless m =~ /^__/ }
  alias class __class__
  alias send  __send__ 


  def initialize &blk
    @status = :pending
    @f = Fiber.new {

      @d = blk.call
      if @d.kind_of? EM::DefaultDeferrable
        @d.callback { |val|
         puts "the future has come! val=#{val}"
         @status = :done
         @f.resume val
        }
        @d.errback { |val|
         puts "the future is dead"
         @status = :dead
         @f.resume val
        }

      else
        "the future was always the present? that's deep dude."
        @result = d
      end
      @result = Fiber.yield
    }
    
    puts "running fiber"
    @f.resume

    
    self
  end

  def method_missing *args, &block
    # if we're not quite done yet... then resume the fiber.
    if @f.alive?
      f = Fiber.current
      @d.callback { |val|
        f.resume val
      }    
      @result = Fiber.yield
      return @result.send(*args, &block)
    else
      @result
    end
  end

end

# nice simple asynchronous rpc. takes something to ask for (and eventually gives it back)
# and return a deferrable in case you want to do something else with the result.
def rpc val, &blk
  d = EventMachine::DefaultDeferrable.new

  EventMachine.add_timer(1) {
    d.succeed(val)
  }

  d
end

EventMachine.run {
  start_time = Time.now
  
  EM.next_tick {
    # Need to wrap this in a fiber so I can block the whole thing 
    # in case the value of a future is demanded.
    f = Fiber.new {
      puts "start future calc"
      start = Time.now
      one = Future.new { rpc(1) }
      two = Future.new { rpc(2) }

      puts "at #{Time.now - start}, about to use futures"
      result = one + two
      puts "finished with futures at #{Time.now - start}"
      puts result
    }
    
    EM.next_tick {
      f.resume
    }
    
  }

  # ensure we eventually do quit
  EventMachine.add_timer(5) {
    puts "Total Runtime: #{Time.now - start_time}"
    EventMachine.stop
  }
   
}