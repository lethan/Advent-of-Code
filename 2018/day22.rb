# frozen_string_literal: true

target_x = 9
target_y = 751
cave_depth = 11_817

def errosion_level(x_coord, y_coord, target_x, target_y, cave_depth)
  @errosion_levels ||= {}
  return @errosion_levels[{ x: x_coord, y: y_coord }] unless @errosion_levels[{ x: x_coord, y: y_coord }].nil?

  geologic_index = if x_coord.zero? && y_coord.zero?
                     0
                   elsif x_coord == target_x && y_coord == target_y
                     0
                   elsif y_coord.zero?
                     x_coord * 16_807
                   elsif x_coord.zero?
                     y_coord * 48_271
                   else
                     errosion_level(x_coord - 1, y_coord, target_x, target_y, cave_depth) * errosion_level(x_coord, y_coord - 1, target_x, target_y, cave_depth)
                   end
  @errosion_levels[{ x: x_coord, y: y_coord }] = (geologic_index + cave_depth) % 20_183
end

total_risk = 0

0.upto(target_x) do |x|
  0.upto(target_y) do |y|
    risk_level = errosion_level(x, y, target_x, target_y, cave_depth) % 3
    total_risk += risk_level
  end
end

puts total_risk

current_equipment = :torch
current_x = 0
current_y = 0
current_time = -1
seen_caves = {}
time_queue = []
time_queue[0] = [] if time_queue[0].nil?
time_queue[0] << [current_x, current_y, current_equipment]
found_route = false
until found_route
  current_states = time_queue.shift
  current_states ||= []
  current_states.uniq.each do |state|
    current_x = state[0]
    current_y = state[1]
    current_equipment = state[2]

    if current_x == target_x && current_y == target_y && current_equipment == :torch
      found_route = true
      break
    end
    next if seen_caves[{ x: current_x, y: current_y, equipment: current_equipment }]

    seen_caves[{ x: current_x, y: current_y, equipment: current_equipment }] = current_time

    -1.upto(1) do |x|
      -1.upto(1) do |y|
        next if x.abs == y.abs
        next if (current_x + x).negative?
        next if (current_y + y).negative?

        new_x = current_x + x
        new_y = current_y + y
        case current_equipment
        when :torch
          if errosion_level(new_x, new_y, target_x, target_y, cave_depth) % 3 != 1
            time_queue[0] ||= []
            time_queue[0] << [new_x, new_y, current_equipment]
          end
        when :climbing
          if errosion_level(new_x, new_y, target_x, target_y, cave_depth) % 3 != 2
            time_queue[0] ||= []
            time_queue[0] << [new_x, new_y, current_equipment]
          end
        when :neither
          if errosion_level(new_x, new_y, target_x, target_y, cave_depth) % 3 != 0
            time_queue[0] ||= []
            time_queue[0] << [new_x, new_y, current_equipment]
          end
        end
      end
    end
    case current_equipment
    when :torch
      time_queue[6] ||= []
      time_queue[6] << [current_x, current_y, :climbing] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 0
      time_queue[6] << [current_x, current_y, :neither] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 2
    when :climbing
      time_queue[6] ||= []
      time_queue[6] << [current_x, current_y, :torch] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 0
      time_queue[6] << [current_x, current_y, :neither] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 1
    when :neither
      time_queue[6] ||= []
      time_queue[6] << [current_x, current_y, :climbing] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 1
      time_queue[6] << [current_x, current_y, :torch] if errosion_level(current_x, current_y, target_x, target_y, cave_depth) % 3 == 2
    end
  end

  current_time += 1
end
puts current_time
