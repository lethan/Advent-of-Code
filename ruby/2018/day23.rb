# frozen_string_literal: true

require 'set'

# Nanobot
class Nanobot
  attr_reader :x, :y, :z, :range, :neighbors

  def initialize(x_coord, y_coord, z_coord, range)
    @x = x_coord
    @y = y_coord
    @z = z_coord
    @range = range
    @neighbors = Set[]
  end

  def distance_to_point(x_coord, y_coord, z_coord)
    (@x - x_coord).abs + (@y - y_coord).abs + (@z - z_coord).abs
  end

  def distance(other)
    distance_to_point(other.x, other.y, other.z)
  end

  def add_neighbor(other)
    common = @range + other.range - distance(other)
    @neighbors << other unless common.negative?
  end
end

file = File.open('../../input/2018/input_day23.txt', 'r')
nanobots = []
while (line = file.gets)
  if (match = /pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/.match(line))
    nanobots << Nanobot.new(*match[1..4].map(&:to_i))
  end
end
file.close

0.upto(nanobots.length - 2) do |b1_index|
  bot1 = nanobots[b1_index]
  (b1_index + 1).upto(nanobots.length - 1) do |b2_index|
    bot2 = nanobots[b2_index]
    bot1.add_neighbor(bot2)
    bot2.add_neighbor(bot1)
  end
end

in_range = 0
higest_range_bot = nanobots.max_by(&:range)

nanobots.each do |bot|
  in_range += 1 if higest_range_bot.distance(bot) <= higest_range_bot.range
end

puts in_range

def bron_kerbosch(r_set, p_set, x_set, result)
  if p_set.empty? && x_set.empty?
    result.clear if r_set.size > (result&.first&.size || 0)
    result << r_set if r_set.size >= (result&.first&.size || 0)
  end
  p_set.each do |current|
    bron_kerbosch(r_set | Set[current], p_set & current.neighbors, x_set & current.neighbors, result)
    p_set.delete(current)
    x_set.add(current)
  end
end

result = []
bron_kerbosch(Set[], nanobots.to_set, Set[], result)

shortest_distance = nil

result.each do |group|
  coordinates = Hash.new(0)
  keep_looking = true

  group.to_a.sort_by(&:range).each do |bot|
    next unless keep_looking

    0.upto(bot.range) do |x|
      [1, -1].each do |x_direction|
        next if x.zero? && x_direction.negative?

        0.upto(bot.range - x) do |y|
          [1, -1].each do |y_direction|
            next if y.zero? && y_direction.negative?

            0.upto(bot.range - x - y) do |z|
              [1, -1].each do |z_direction|
                next if z.zero? && z_direction.negative?

                coordinates[{ x: bot.x + x * x_direction, y: bot.y + y * y_direction, z: bot.z + z * z_direction }] += 1
              end
            end
          end
        end
      end
    end

    max_overlay = coordinates.values.max
    keep_looking = false if coordinates.select { |_, v| v == max_overlay }.size == 1
  end
  max_overlay = coordinates.values.max
  coordinates.select { |_, v| v == max_overlay }.each do |k, _|
    distance = k[:x].abs + k[:y].abs + k[:z].abs
    shortest_distance ||= distance
    shortest_distance = distance if distance < shortest_distance
  end
end

puts shortest_distance
