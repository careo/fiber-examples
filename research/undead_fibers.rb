require 'fiber'

f = Fiber.new {
  puts "  it's alive!"
}

puts "have *not* resumed #{f}"
puts "Is it alive? => #{f.alive?}"

puts "Resuming #{f}..."
f.resume
puts "How alive is it now? => #{f.alive?}"

