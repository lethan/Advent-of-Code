# frozen_string_literal: true

require 'set'

file = File.open('input_day24.txt', 'r')
maze = []
row_number = 0
points = {}
while (line = file.gets)
  row = []
  line.chomp.split('').each_with_index do |value, index|
    path = true
    case value
    when '#'
      path = false
    when *(0..9).to_a.map(&:to_s)
      points[value.to_i] = { x: index, y: row_number }
    else
      puts "UNKOWN INPUT: '#{value}'" if value != '.'
    end
    row << path
  end
  maze << row
  row_number += 1
end
file.close

distances = {}
points_from_coord = Hash[points.map { |k, v| [v, k] }]

points.each do |start_point, start_coord|
  visited = {}
  queue = []
  seen_points = 0
  queue << [start_coord, 0]
  while (current = queue.shift)
    coord = current.first
    steps = current.last
    next if visited[coord]

    visited[coord] = steps
    if (new_point = points_from_coord[coord]) && new_point != start_point
      distances[Set[start_point, new_point]] = steps
      seen_points += 1
    end

    break if seen_points == points.length - 1

    -1.upto(1) do |x|
      -1.upto(1) do |y|
        next if x.abs == y.abs

        new_coord = { x: coord[:x] + x, y: coord[:y] + y }
        queue << [new_coord, steps + 1] if maze[new_coord[:y]][new_coord[:x]] && visited[new_coord].nil?
      end
    end
  end
end

def shortest_route(distances, visited, pending, return_home = false)
  return (return_home ? distances[Set[visited.last, 0]] : 0) if pending.empty?

  minimum_value = nil
  pending.each do |point|
    value = distances[Set[visited.last, point]] + shortest_route(distances, visited + [point], pending - [point], return_home)
    minimum_value = value if minimum_value.nil? || value < minimum_value
  end
  minimum_value
end

puts shortest_route(distances, [0], (1..7).to_a)
puts shortest_route(distances, [0], (1..7).to_a, true)
