# frozen_string_literal: true

require 'set'

Instruction = Struct.new(:direction, :distance)

file = File.open('input_day03.txt', 'r')
wires = []
while (line = file.gets)
  wires << line.strip.split(',').map do |input|
    direction = case input[0]
                when 'U'
                  :up
                when 'D'
                  :down
                when 'R'
                  :right
                when 'L'
                  :left
                end
    Instruction.new(direction, input[1..-1].to_i)
  end
end
file.close

wire_map = {}
step_map = []

closest_collision = nil
fastest_collision = nil

wires.each_with_index do |wire, index|
  current_x = 0
  current_y = 0
  current_steps = 0
  step_map[index] = {}

  wire.each do |instruction|
    direction = instruction.direction
    steps = instruction.distance

    while steps >= 1
      current_steps += 1

      case direction
      when :up
        current_y += 1
      when :down
        current_y -= 1
      when :right
        current_x += 1
      when :left
        current_x -= 1
      end

      wire_map[[current_x, current_y]] = Set.new if wire_map[[current_x, current_y]].nil?
      step_map[index][[current_x, current_y]] = current_steps if step_map[index][[current_x, current_y]].nil?

      wire_map[[current_x, current_y]] << index
      if wire_map[[current_x, current_y]].size > 1
        manhattan_distance = current_x.abs + current_y.abs
        closest_collision = manhattan_distance if closest_collision.nil? || manhattan_distance < closest_collision

        timing_distance = 0
        wire_map[[current_x, current_y]].each do |wire_index|
          timing_distance += step_map[wire_index][[current_x, current_y]]
        end
        fastest_collision = timing_distance if fastest_collision.nil? || timing_distance < fastest_collision
      end

      steps -= 1
    end
  end
end

puts closest_collision
puts fastest_collision
