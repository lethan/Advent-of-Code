file = File.open('input_day03.txt', 'r')
squares = []
while line = file.gets
  if match = /#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/.match(line)
    squares << { id: match[1].to_i, x: match[2].to_i, y: match[3].to_i, width: match[4].to_i, height: match[5].to_i, valid: true }
  end
end
file.close

used_squares = {}

squares.each do |square|
  square[:x].upto(square[:x] + square[:width] - 1) do |x|
    square[:y].upto(square[:y] + square[:height] - 1) do |y|
      if used_squares[{x: x, y: y}].nil?
        used_squares[{x: x, y: y}] = []
      end
      used_squares[{x: x, y: y}] << square[:id]
    end
  end
end

puts used_squares.values.select { |num| num.length > 1 }.length

squares.each do |square|
  square[:x].upto(square[:x] + square[:width] - 1) do |x|
    square[:y].upto(square[:y] + square[:height] - 1) do |y|
      if used_squares[{x: x, y: y}].length > 1
        square[:valid] = false
      end
    end
  end
end

puts squares.select { |sq| sq[:valid] }[0][:id]
