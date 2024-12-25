# frozen_string_literal: true

require 'set'

asteroid_map = []
asteroid_coords = []
file = File.open('../../input/2019/input_day10.txt', 'r')
row = 0
while (line = file.gets)
  asteroid_row = line.strip.split('').map { |c| c == '#' }
  asteroid_map << asteroid_row
  asteroid_row.each_with_index { |val, index| asteroid_coords << [index, row] if val }
  row += 1
end
file.close

visible_directions = {}
asteroid_coords.each_with_index do |asteroid_a, index|
  (index + 1).upto(asteroid_coords.size - 1) do |index2|
    asteroid_b = asteroid_coords[index2]
    x = asteroid_b[0] - asteroid_a[0]
    y = asteroid_b[1] - asteroid_a[1]
    gcd = x.gcd(y)
    x /= gcd
    y /= gcd
    visible_directions[asteroid_a] = Set.new if visible_directions[asteroid_a].nil?
    visible_directions[asteroid_a] << [x, y]
    visible_directions[asteroid_b] = Set.new if visible_directions[asteroid_b].nil?
    visible_directions[asteroid_b] << [-x, -y]
  end
end

max_visible = 0
center_asteroid = nil
visible_directions.each do |key, val|
  if val.size > max_visible
    max_visible = val.size
    center_asteroid = key
  end
end
puts max_visible

directions = visible_directions[center_asteroid].to_a.sort_by { |a| -(Math.atan2(a[0], a[1]) - Math::PI / 4) }
destroyed_two_hundred = 0
destroy_count = 0
while destroy_count <= 200
  directions.each do |direction|
    x_coord = center_asteroid[0]
    y_coord = center_asteroid[1]
    found = false
    out_off_bounds = false
    until found || out_off_bounds
      x_coord += direction[0]
      y_coord += direction[1]
      out_off_bounds = true if x_coord.negative? || y_coord.negative? || y_coord >= asteroid_map.size || x_coord >= asteroid_map[y_coord].size
      next if out_off_bounds
      next unless asteroid_map[y_coord][x_coord]

      found = true
      destroy_count += 1
      destroyed_two_hundred = x_coord * 100 + y_coord if destroy_count == 200
      asteroid_map[y_coord][x_coord] = false
    end
  end
end
puts destroyed_two_hundred
