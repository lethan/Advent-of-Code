file = File.open("input_day11.txt", "r")
input = []
while line = file.gets
  input += line.split(/\W+/)
end
file.close

def distance(input, part=1)
  x = 0
  y = 0
  z = 0
  max_distance = 0
  input.each do |direction|
    case direction
    when 'n'
      y += 1
      z -= 1
    when 's'
      y -= 1
      z += 1
    when 'ne'
      x += 1
      z -= 1
    when 'nw'
      x -= 1
      y += 1
    when 'se'
      x += 1
      y -= 1
    when 'sw'
      z += 1
      x -= 1
    else
      puts "unknown direction #{direction.inspect}"
    end
    max_distance = (x.abs + y.abs + z.abs)/2 if (x.abs + y.abs + z.abs)/2 > max_distance
  end
  (part==2) ? max_distance : (x.abs + y.abs + z.abs)/2
end

puts distance(input)
puts distance(input, 2)
