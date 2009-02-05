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
