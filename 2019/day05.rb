# frozen_string_literal: true

file = File.open('input_day05.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

def run_program(program, inputs)
  input = program.clone
  output = []
  pointer = 0

  while pointer >= 0
    mode_one = input[pointer] / 100 % 10
    mode_two = input[pointer] / 1000 % 10
    mode_three = input[pointer] / 10_000 % 10
    case input[pointer] % 100
    when 1
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      input[input[pointer + 3]] = parameter_one + parameter_two
      pointer += 4
    when 2
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      input[input[pointer + 3]] = parameter_one * parameter_two
      pointer += 4
    when 3
      input[input[pointer + 1]] = inputs.shift
      pointer += 2
    when 4
      output << input[input[pointer + 1]]
      pointer += 2
    when 5
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      pointer += 3
      pointer = parameter_two unless parameter_one.zero?
    when 6
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      pointer += 3
      pointer = parameter_two if parameter_one.zero?
    when 7
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      input[input[pointer + 3]] = parameter_one < parameter_two ? 1 : 0
      pointer += 4
    when 8
      parameter_one = mode_one.zero? ? input[input[pointer + 1]] : input[pointer + 1]
      parameter_two = mode_two.zero? ? input[input[pointer + 2]] : input[pointer + 2]
      input[input[pointer + 3]] = parameter_one == parameter_two ? 1 : 0
      pointer += 4
    when 99
      break
    else
      puts "Unknown operation: #{pointer} = #{input[pointer]}"
      break
    end
  end

  output
end

puts run_program(program, [1]).last
puts run_program(program, [5])
