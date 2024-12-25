# frozen_string_literal: true

require 'set'

key_map = []
key_locations = {}
row_number = 0
file = File.open('../../input/2019/input_day18.txt', 'r')
while (line = file.gets)
  row = line.strip.split('').each_with_index.map do |char, index|
    case char
    when '.'
      { type: :empty }
    when /[a-z]/
      key_locations[char] = { x: index, y: row_number }
      { type: :key, key: char }
    when /[A-Z]/
      { type: :door, key: char.downcase }
    when '#'
      { type: :wall }
    when '@'
      { type: :start }
    end
  end
  key_map << row
  row_number += 1
end
file.close

def steps_to_other(key_map, start, step, visited, required)
  steps_to_other = {}
  required = required.clone

  visited[start] = {} if visited[start].nil?
  visited[start][required] = step

  square = key_map[start[:y]][start[:x]]
  if square[:type] == :key
    key = square[:key]
    steps_to_other[key] = {} if steps_to_other[key].nil?
    steps_to_other[key][required] = step
  end

  if square[:type] == :start
    steps_to_other['@'] = {} if steps_to_other['@'].nil?
    steps_to_other['@'][required] = step
  end

  required << square[:key] if square[:type] == :door

  (-1..1).each do |y|
    (-1..1).each do |x|
      next if y.abs == x.abs
      next if key_map[start[:y] + y][start[:x] + x] == { type: :wall }

      new_start = { x: start[:x] + x, y: start[:y] + y }

      skip_visit = false
      visited[new_start]&.each do |k, value|
        skip_visit ||= k & required == k && value <= step + 1
      end
      next if skip_visit

      other = steps_to_other(key_map, new_start, step + 1, visited, required)
      steps_to_other.merge!(other)
    end
  end
  steps_to_other
end

def distances_with_requirements(key_map, key_locations)
  new_map = []
  key_map.each do |row|
    new_row = []
    row.each do |column|
      new_row << column.clone
    end
    new_map << new_row
  end
  distances = {}
  key_locations.each do |key, location|
    new_map[location[:y]][location[:x]] = { type: :empty }
    distances[key] = {} if distances[key].nil?
    steps_to_other(new_map, location, 0, {}, []).each do |s_i, step_val|
      distances[key][s_i] = step_val
      distances[s_i] = {} if distances[s_i].nil?
      distances[s_i][key] = step_val
    end
  end
  distances
end

def shortest_path(start_location, key_map, key_locations)
  distances = distances_with_requirements(key_map, key_locations)
  current_location = ([] << start_location).flatten.to_set
  current_visited = Set.new
  current_distance = 0
  best_distance = nil
  seen_states = {}
  queue = []
  queue << [current_location, current_visited, current_distance]

  while (current_location, current_visited, current_distance = queue.shift)
    next if seen_states[[current_location, current_visited]] && seen_states[[current_location, current_visited]] <= current_distance
    next if best_distance && current_distance > best_distance

    seen_states[[current_location, current_visited]] = current_distance

    if distances.keys.to_set == current_location + current_visited
      best_distance = current_distance if best_distance.nil? || best_distance > current_distance
    end

    current_location.each do |location|
      possible_locations = distances[location].reject { |k, _| (current_visited + current_location).include?(k) }
      possible_locations = possible_locations.select { |_, value| value.keys.any? { |key| key.to_set <= (current_visited + current_location) } }
      possible_locations.sort_by { |_, v| v.values }.each do |new_location, value|
        value.sort.each do |key, distance_to_key|
          next if key.to_set > current_visited

          to_location = current_location - [location] + [new_location]
          new_visited = current_visited + [location]
          new_distance = current_distance + distance_to_key

          queue << [to_location, new_visited, new_distance]
        end
      end
    end
  end
  best_distance
end

puts shortest_path('@', key_map, key_locations)

y = key_map.index { |tmp_row| tmp_row.include?(type: :start) }
x = key_map[y].index(type: :start)
counter = 1
(-1..1).each do |y_diff|
  (-1..1).each do |x_diff|
    if x_diff.abs == 1 && y_diff.abs == 1
      key_map[y + y_diff][x + x_diff] = { type: :key, key: counter.to_s }
      counter += 1
    else
      key_map[y + y_diff][x + x_diff] = { type: :wall }
    end
  end
end

puts shortest_path(%w[1 2 3 4], key_map, key_locations)
