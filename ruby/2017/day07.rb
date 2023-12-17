class Program
  attr_reader :name
  attr_reader :weight
  attr_accessor :sub_programs

  def initialize(name, weight)
    @name = name
    @weight = weight
  end
end

file = File.open("../../input/2017/input_day07.txt", "r")
input = []
while line = file.gets
  match = /(\S+) \((\d+)\)( -> (.+))?/.match(line)
  program = Program.new(match[1], match[2].to_i)
  program.sub_programs = match[4].split(', ') if match[4]
  input << [match[1], program]
end
file.close

def subtree(current, input)
  if !current[0].is_a?(Program)
    name = current[0]
    program = current[1]
    if !program.sub_programs.nil?
      program.sub_programs.each_with_index do |sub, program_index|
        input.select.with_index do |value, input_index|
          if sub == value[0]
            program.sub_programs[program_index] = input[input_index]
            input.delete_at(input_index)
            subtree(program.sub_programs[program_index], input)
            program.sub_programs[program_index] = program.sub_programs[program_index][1]
            break
          end
        end
      end
    end
  end
end

while input.length > 1 do
  input.each_with_index do |current, index|
    if !input[index].nil?
      if !current[1].sub_programs.nil?
        subtree(current, input)
      end
    end
  end
end

puts input[0][0]

def subweights(program)
  weight = program.weight
  subweights = []
  if !program.sub_programs.nil?
    program.sub_programs.each do |sub|
      subweights << subweights(sub)
    end
    if !subweights.all? { |w| w == subweights[0] }
      if subweights.count(subweights[0]) == 1
        puts program.sub_programs[0].weight - subweights[0] + subweights[1]
        subweights[0] = subweights[1]
      else
        subweights.each_with_index do |s, i|
          if s != subweights[0]
            puts program.sub_programs[i].weight - subweights[i] + subweights[0]
            subweights[i] = subweights[0]
          end
        end
      end
    end
  end
  weight + subweights.inject(0, :+)
end

input = input[0][1]
subweights(input)

