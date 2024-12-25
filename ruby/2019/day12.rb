# frozen_string_literal: true

file = File.open('../../input/2019/input_day12.txt', 'r')
moons = []
while (line = file.gets)
  if (match = /<x=(-?\d+), y=(-?\d+), z=(-?\d+)>/.match(line))
    moons << { x_pos: match[1].to_i, y_pos: match[2].to_i, z_pos: match[3].to_i, x_vel: 0, y_vel: 0, z_vel: 0 }
  end
end
file.close

seen_x = false
x_start = moons.flat_map { |moon| [moon[:x_pos], moon[:x_vel]] }
x_ticks = nil
seen_y = false
y_start = moons.flat_map { |moon| [moon[:y_pos], moon[:y_vel]] }
y_ticks = nil
seen_z = false
z_start = moons.flat_map { |moon| [moon[:z_pos], moon[:z_vel]] }
z_ticks = nil
tick = 0
until seen_x && seen_y && seen_z && tick >= 1000
  tick += 1
  moons.each_with_index do |moon_a, index|
    ((index + 1)..(moons.size - 1)).each do |index2|
      moon_b = moons[index2]
      %i[x_pos y_pos z_pos].each do |axis|
        vel = case axis
              when :x_pos
                :x_vel
              when :y_pos
                :y_vel
              when :z_pos
                :z_vel
              end
        case moon_a[axis] <=> moon_b[axis]
        when -1
          moon_a[vel] += 1
          moon_b[vel] -= 1
        when 1
          moon_a[vel] -= 1
          moon_b[vel] += 1
        end
      end
    end
  end
  moons.each do |moon|
    moon[:x_pos] += moon[:x_vel]
    moon[:y_pos] += moon[:y_vel]
    moon[:z_pos] += moon[:z_vel]
  end
  if !seen_x && x_start == moons.flat_map { |moon| [moon[:x_pos], moon[:x_vel]] }
    x_ticks = tick
    seen_x = true
  end
  if !seen_y && y_start == moons.flat_map { |moon| [moon[:y_pos], moon[:y_vel]] }
    y_ticks = tick
    seen_y = true
  end
  if !seen_z && z_start == moons.flat_map { |moon| [moon[:z_pos], moon[:z_vel]] }
    z_ticks = tick
    seen_z = true
  end

  next unless tick == 1000

  total_energy = 0
  moons.each do |moon|
    total_energy += [moon[:x_pos].abs, moon[:y_pos].abs, moon[:z_pos].abs].sum * [moon[:x_vel].abs, moon[:y_vel].abs, moon[:z_vel].abs].sum
  end
  puts total_energy
end
puts x_ticks.lcm(y_ticks).lcm(z_ticks)
