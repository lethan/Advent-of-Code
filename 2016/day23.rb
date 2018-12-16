# frozen_string_literal: true

file = File.open('input_day23.txt', 'r')
program = []
while (line = file.gets)
  program << line.chomp
end
file.close

def run(program, registers)
  pointer = 0
  while pointer < program.length
    instruction = program[pointer].split(' ')
    case instruction[0]
    when 'cpy'
      if instruction[1].to_i.to_s == instruction[1]
        registers[instruction[2]] = instruction[1].to_i if instruction[2].to_i.to_s != instruction[2]
      else
        registers[instruction[2]] = registers[instruction[1]] if instruction[2].to_i.to_s != instruction[2]
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
      if cmp == 0
        pointer += 1
      else
        pointer += instruction[2].to_i.to_s == instruction[2] ? instruction[2].to_i : registers[instruction[2]]
      end
    when 'tgl'
      command_pointer = pointer + (instruction[1].to_i.to_s == instruction[1] ? :instruction[1].to_i : registers[instruction[1]])
      unless program[command_pointer].nil?
        new_instruction = program[command_pointer].split(' ')
        case new_instruction[0]
        when 'dec', 'tgl'
          new_instruction[0] = 'inc'
          program[command_pointer] = new_instruction.join(' ')
        when 'inc'
          new_instruction[0] = 'dec'
          program[command_pointer] = new_instruction.join(' ')
        when 'jnz'
          new_instruction[0] = 'cpy'
          program[command_pointer] = new_instruction.join(' ')
        when 'cpy'
          new_instruction[0] = 'jnz'
          program[command_pointer] = new_instruction.join(' ')
        end
      end
      pointer += 1
    else
      puts "unknown instruction: #{program[pointer]}"
    end
  end
  registers['a']
end

registers = Hash.new(0)
registers['a'] = 7
puts run(program.dup, registers)
registers = Hash.new(0)
registers['a'] = 12
puts run(program.dup, registers)
