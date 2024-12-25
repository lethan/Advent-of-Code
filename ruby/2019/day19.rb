# frozen_string_literal: true

require_relative 'intcode'

program = []
file = File.open('../../input/2019/input_day19.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

def print_beam(points)
  x_min, x_max = points.keys.map { |a| a[:x] }.minmax
  y_min, y_max = points.keys.map { |a| a[:y] }.minmax
  (y_min..y_max).each do |y|
    (x_min..x_max).each do |x|
      print points[{ x: x, y: y }].zero? ? '.' : '#'
    end
    puts
  end
end

def check_in_beam(beamer, x_coord, y_coord)
  return false if x_coord.negative? || y_coord.negative?

  beamer.restart.input(x_coord).input(y_coord).output == 1
end

beam_checker = Program.new(program)
points = {}
affected = 0
(0..49).each do |x|
  (0..49).each do |y|
    status = beam_checker.restart.input(x).input(y).output
    points[{ x: x, y: y }] = status
    affected += 1 if status == 1
  end
end
puts affected

in_beam = points.select { |k, v| v == 1 && points[{ x: k[:x] + 1, y: k[:y] + 1 }] == 1 }
upper_bound_x = in_beam.keys.map { |a| a[:x] }.min
upper_bound_y = in_beam.keys.map { |a| a[:y] }.min
needed_size = 100

left = upper_bound_x - (needed_size - 1)
downer = upper_bound_y + (needed_size - 1)
until check_in_beam(beam_checker, left, downer)
  upper_bound_y += 1
  upper_bound_x += 1 while check_in_beam(beam_checker, upper_bound_x + 1, upper_bound_y)
  left = upper_bound_x - (needed_size - 1)
  downer = upper_bound_y + (needed_size - 1)
end
puts left * 10_000 + upper_bound_y
