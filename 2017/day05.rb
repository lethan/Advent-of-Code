file = File.open("input_day05.txt", "r")
input = []
while line = file.gets
  line = line.to_i
  input << line
end
file.close

def steps(input, part=0)
  step = 0
  current = 0
  working = input.clone
  size = working.length
  while current < size do
    step += 1
    jump = working[current]
    working[current] += 1 if part==0 || jump < 3
    working[current] -= 1 if part!=0 && jump >= 3
    current += jump
  end
  step
end

puts steps(input)
puts steps(input, 1)
