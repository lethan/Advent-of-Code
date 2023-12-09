file = File.open("../../input/2015/input_day01.txt", "r")
floor = 0
step = 0
position = 0
while line = file.gets
  line.split('').each do |direction|
    step += 1
    floor += 1 if direction == "("
    floor -= 1 if direction == ")"
    if floor == -1 && position == 0
      position = step
    end
  end
end
file.close

puts floor
puts position
