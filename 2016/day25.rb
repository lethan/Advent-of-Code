# frozen_string_literal: true

file = File.open('input_day25.txt', 'r')
program = []
while (line = file.gets)
  program << line.chomp
end
file.close

def infinite_clock_signal(program, registers)
  seen_states = Hash.new(false)
  pointer = 0
  last_out = nil
  while pointer < program.length
    instruction = program[pointer].split(' ')
    case instruction[0]
    when 'cpy'
      registers[instruction[2]] = if instruction[1].to_i.to_s == instruction[1]
                                    instruction[1].to_i
                                  else
                                    registers[instruction[1]]
                                  end
      pointer += 1
    when 'inc'
      registers[instruction[1]] = registers[instruction[1]] + 1
      pointer += 1
    when 'dec'
      registers[instruction[1]] = registers[instruction[1]] - 1
      pointer += 1
    when 'jnz'
      cmp = instruction[1].to_i.to_s == instruction[1] ? instruction[1].to_i : registers[instruction[1]]
      pointer += cmp.zero? ? 1 : instruction[2].to_i
    when 'out'
      break unless [0, 1].include?(registers[instruction[1]])
      break if registers[instruction[1]] == last_out && !last_out.nil?

      return true if seen_states[[registers.dup, pointer]]

      seen_states[[registers.dup, pointer]] = true
      last_out = registers[instruction[1]]
      pointer += 1
    else
      puts "unknown instruction: #{program[pointer]}"
    end
  end
  false
end

registers = Hash.new(0)
counter = 0
registers['a'] = counter
until infinite_clock_signal(program.dup, registers)
  counter += 1
  registers = Hash.new(0)
  registers['a'] = counter
end
puts counter
