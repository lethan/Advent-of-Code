require 'prime'

file = File.open('input_day23.txt', 'r')
program = []
while line = file.gets
  program << line.chomp
end
file.close


def run(program, registers)
  pointer = 0
  mul_counter = 0
  while pointer < program.length
    instruction = program[pointer].split(' ')
    case instruction[0]
    when 'set'
      registers[instruction[1]] = instruction[2].to_i.to_s == instruction[2] ? instruction[2].to_i : registers[instruction[2]]
      pointer += 1
    when 'sub'
      registers[instruction[1]] -= instruction[2].to_i.to_s == instruction[2] ? instruction[2].to_i : registers[instruction[2]]
      pointer += 1
    when 'mul'
      registers[instruction[1]] *= instruction[2].to_i.to_s == instruction[2] ? instruction[2].to_i : registers[instruction[2]]
      mul_counter += 1
      pointer += 1
    when 'jnz'
      cmp = instruction[1].to_i.to_s == instruction[1] ? instruction[1].to_i : registers[instruction[1]]
      if cmp == 0
        pointer += 1
      else
        pointer += instruction[2].to_i.to_s == instruction[2] ? instruction[2].to_i : registers[instruction[2]]
      end
    end
  end
  mul_counter
end

puts run(program, Hash.new(0))

primes = 0
(105700..122700).step(17).each { |a| primes += 1 if !a.prime?}
puts primes
