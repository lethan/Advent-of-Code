# frozen_string_literal: true

file = File.open('input_day08.txt', 'r')
while (line = file.gets)
  bits = line.strip.split('').map(&:to_i)
end
file.close

width = 25
height = 6

layers = bits.each_slice(width * height).to_a

fewest_zeroes = nil
result = nil

image = Array.new(width * height, nil)

layers.each do |layer|
  zeroes = layer.count(0)
  if fewest_zeroes.nil? || zeroes < fewest_zeroes
    fewest_zeroes = zeroes
    result = layer.count(1) * layer.count(2)
  end

  layer.each_with_index do |pixel, index|
    image[index] ||= pixel if pixel != 2
  end
end

puts result

image.each_slice(width) do |row|
  puts row.map { |val| val == 1 ? '#' : ' ' }.join
end
