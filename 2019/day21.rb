# frozen_string_literal: true

require_relative 'intcode'

program = []
file = File.open('input_day21.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

spring_bot = Program.new(program)

walking_instructions = %(OR A J
AND B J
AND C J
NOT J J
AND D J
WALK
)
spring_bot.input_string(walking_instructions)
last_out = spring_bot.output while spring_bot.outputs?
puts last_out

running_instructions = %(OR A J
AND B J
AND C J
NOT J J
AND D J
OR E T
OR H T
AND T J
RUN
)

spring_bot.restart
spring_bot.input_string(running_instructions)
last_out = spring_bot.output while spring_bot.outputs?
puts last_out
