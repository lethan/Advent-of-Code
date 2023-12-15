def input
  1358
end

def valid_field(x_coord, y_coord)
  return false if x_coord < 0 || y_coord < 0

  val = x_coord * x_coord + 3 * x_coord + 2 * x_coord * y_coord + y_coord + y_coord * y_coord + input
  val.to_s(2).count('1').even?
end

visited = {}
queuee = []
visited[{ x_coord: 1, y_coord: 1 }] = 0
queuee << { x_coord: 1, y_coord: 1 }
while (coord = queuee.shift)
  break if coord[:x_coord] == 31 && coord[:y_coord] == 39
  step = visited[coord]
  new_coords = []
  new_coords << { x_coord: coord[:x_coord] - 1, y_coord: coord[:y_coord] } # Left
  new_coords << { x_coord: coord[:x_coord] + 1, y_coord: coord[:y_coord] } # Right
  new_coords << { x_coord: coord[:x_coord], y_coord: coord[:y_coord] - 1 } # Up
  new_coords << { x_coord: coord[:x_coord], y_coord: coord[:y_coord] + 1 } # Down

  new_coords.each do |new_coord|
    if valid_field(new_coord[:x_coord], new_coord[:y_coord]) && visited[new_coord].nil?
      visited[new_coord] = step + 1
      queuee << new_coord
    end
  end
end

puts visited[{ x_coord: 31, y_coord: 39 }]
puts visited.values.select { |v| v <= 50 }.count
