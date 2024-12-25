# frozen_string_literal: true

maze_input = []
file = File.open('../../input/2019/input_day20.txt', 'r')
while (line = file.gets)
  maze_input << line.chomp.split('')
end
file.close

portals = {}
maze = {}
maze_input.each_with_index do |row, row_number|
  row.each_with_index do |column, column_number|
    coordinate = { x: column_number, y: row_number }
    case column
    when '.'
      maze[coordinate] = { type: :empty }
    when '#'
      maze[coordinate] = { type: :wall }
    when /[A-Z]/
      (-1..1).each do |x|
        (-1..1).each do |y|
          next if x.abs == y.abs
          next if (row_number + y).negative?
          next if (column_number + x).negative?
          next if (row_number + y) >= maze_input.size
          next if row_number + y >= maze_input.size
          next if column_number + x >= row.size

          if maze_input[row_number + y][column_number + x] == '.'
            portal_other_letter = maze_input[row_number - y][column_number - x]
            portal = (x + y).positive? ? portal_other_letter + column : column + portal_other_letter
            portals[portal] = [] if portals[portal].nil?
            direction = nil
            direction ||= :out if column_number == 1
            direction ||= :out if column_number == row.size - 2
            direction ||= :out if row_number == 1
            direction ||= :out if row_number == maze_input.size - 2
            direction ||= :in
            portals[portal] << { x: column_number + x, y: row_number + y, direction: direction }
            maze[coordinate] = { type: :portal, portal: portal }
          end
        end
      end
    end
  end
end

def path_steps(from, destination, maze, portals, inner_maze = false)
  queue = []
  current_step = 0
  current_level = 0
  current_location = portals[from].first.select { |k| %i[x y].include?(k) }
  queue << [current_location, current_step, current_level]
  end_coordinate = portals[destination].first.select { |k| %i[x y].include?(k) }
  end_location = [end_coordinate, current_level]
  visited = {}
  path_steps = nil
  found_route = false

  until found_route
    current_location, current_step, current_level = queue.shift
    next if visited[[current_location, current_level]]

    if end_location == [current_location, current_level]
      path_steps = current_step
      found_route = true
    end
    visited[[current_location, current_level]] = current_step
    (-1..1).each do |x|
      (-1..1).each do |y|
        next if x.abs == y.abs

        new_location = { x: current_location[:x] + x, y: current_location[:y] + y }
        next if maze[new_location].nil?
        next if visited[[new_location, current_level]]

        queue << [new_location, current_step + 1, current_level] if maze[new_location][:type] == :empty
        if maze[new_location][:type] == :portal
          portal_to = portals[maze[new_location][:portal]]

          if inner_maze
            if portal_to.size > 1
              portal_to_direction = portal_to.select { |l| l[:x] == current_location[:x] && l[:y] == current_location[:y] }.first[:direction]
              portal_to = portal_to.reject { |l| l[:x] == current_location[:x] && l[:y] == current_location[:y] }
              portal_to_coordinate = portal_to.first.select { |k| %i[x y].include?(k) }
              case portal_to_direction
              when :in
                queue << [portal_to_coordinate, current_step + 1, current_level + 1] unless visited[[portal_to_coordinate, current_level + 1]]
              when :out
                queue << [portal_to_coordinate, current_step + 1, current_level - 1] unless visited[[portal_to_coordinate, current_level - 1]] || current_level.zero?
              end
            end
          else
            portal_to = portal_to.reject { |l| l[:x] == current_location[:x] && l[:y] == current_location[:y] } if portal_to.size > 1
            portal_to_coordinate = portal_to.first.select { |k| %i[x y].include?(k) }
            queue << [portal_to_coordinate, current_step + 1, current_level] unless visited[[portal_to_coordinate, current_level]]
          end
        end
      end
    end
  end
  path_steps
end

puts path_steps('AA', 'ZZ', maze, portals)
puts path_steps('AA', 'ZZ', maze, portals, true)
