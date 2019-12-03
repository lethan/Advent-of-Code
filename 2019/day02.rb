# frozen_string_literal: true

file = File.open('input_day02.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

def run_program(program, noun, verb)
  input = program.clone
  input[1] = noun
  input[2] = verb
  pointer = 0

  while pointer >= 0
    case input[pointer]
    when 1
      input[input[pointer + 3]] = input[input[pointer + 1]] + input[input[pointer + 2]]
    when 2
      input[input[pointer + 3]] = input[input[pointer + 1]] * input[input[pointer + 2]]
    when 99
      break
    else
      puts "Unknown operation: #{pointer} = #{input[pointer]}"
      break
    end

    pointer += 4
  end

  input[0]
end

puts run_program(program, 12, 2)

noun = 0
verb = 0
result = run_program(program, noun, verb)
until result == 19_690_720
  noun += 1
  if noun > 99
    verb += 1
    noun = 0
  end
  result = run_program(program, noun, verb)
end
puts 100*noun + verb
