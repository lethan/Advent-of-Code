file = File.open('input_day23.txt', 'r')
program = []
while line = file.gets
  program << line.chomp
end
file.close

def run(program, registers)
  pointer = 0
  while pointer < program.length
    instruction = program[pointer].split(' ')
    case instruction[0]
    when 'hlf'
      registers[instruction[1]] = registers[instruction[1]] / 2
      pointer += 1
    when 'tpl'
      registers[instruction[1]] = registers[instruction[1]] * 3
      pointer += 1
    when 'inc'
      registers[instruction[1]] = registers[instruction[1]] + 1
      pointer += 1
    when 'jmp'
      pointer += instruction[1].to_i
    when 'jie'
      instruction[1] = instruction[1][0]
      if registers[instruction[1]] % 2 == 0
        pointer += instruction[2].to_i
      else
        pointer += 1
      end
    when 'jio'
      instruction[1] = instruction[1][0]
      if registers[instruction[1]] == 1
        pointer += instruction[2].to_i
      else
        pointer += 1
      end
    else
      puts "unknown instruction: #{instruction}"
    end
  end
  registers['b']
end

puts run(program, Hash.new(0))
puts run(program, {'a' => 1, 'b' => 0})
