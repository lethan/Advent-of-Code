file = File.open('input_day12.txt', 'r')
program = []
while line = file.gets
  program << line.chomp
end
file.close

def run(program, registers)
  pointer = 0
  while pointer < program.length do
    instruction = program[pointer].split(' ')
    case instruction[0]
    when 'cpy'
      if instruction[1].to_i.to_s == instruction[1]
        registers[instruction[2]] = instruction[1].to_i
      else
        registers[instruction[2]] = registers[instruction[1]]
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
        pointer += instruction[2].to_i
      end
    else
      puts "unknown instruction: #{program[pointer]}"
    end
  end
  registers['a']
end

puts run(program, Hash.new(0))
registers = Hash.new(0)
registers['c'] = 1
puts run(program, registers)
