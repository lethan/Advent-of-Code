# frozen_string_literal: true

require_relative 'intcode'

program = []
file = File.open('input_day25.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

droid = Program.new(program)

puts droid.output_string
until droid.ended?
  droid.input_string(gets)
  puts droid.output_string
end
