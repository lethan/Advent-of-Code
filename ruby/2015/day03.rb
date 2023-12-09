file = File.open("input_day03.txt", "r")
input = []
while line = file.gets
  input += line.split('')
end
file.close

def visited(input)
  visited = {[0,0] => true}
  x = 0
  y = 0
  input.each do |direction|
    x += 1 if direction == ">"
    x -= 1 if direction == "<"
    y += 1 if direction == "^"
    y -= 1 if direction == "v"
    visited[[x,y]] = true
  end
  visited
end

puts visited(input).count

santa,robo = input.partition.each_with_index{ |el, i| i.even? }
puts visited(santa).merge(visited(robo)).count
