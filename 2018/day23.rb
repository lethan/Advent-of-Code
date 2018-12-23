# frozen_string_literal: true

Nanobot = Struct.new(:x, :y, :z, :range)

file = File.open('input_day23.txt', 'r')
nanobots = []
while (line = file.gets)
  if (match = /pos=<(-?\d+),(-?\d+),(-?\d+)>, r=(\d+)/.match(line))
    nanobots << Nanobot.new(*match[1..4].map(&:to_i))
  end
end
file.close

in_range = 0
higest_range_bot = nanobots.max_by(&:range)

nanobots.each do |bot|
  distance = [bot.x - higest_range_bot.x, bot.y - higest_range_bot.y, bot.z - higest_range_bot.z].map(&:abs).sum
  in_range += 1 if distance <= higest_range_bot.range
end

puts in_range
