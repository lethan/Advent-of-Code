file = File.open('../../input/2017/input_day19.txt', 'r')
path_diagram = []
while line = file.gets
  row = line.chomp.split('')
  path_diagram << row
end
file.close

x = 0
y = 0
path_diagram[0].each_with_index do |value, index|
  x = index if value == '|'
end

max_x = path_diagram[0].length - 1
max_y = path_diagram.length - 1
output = ''
steps = 1
direction = :down

while true
  case direction
  when :right
    x += 1
  when :left
    x -= 1
  when :down
    y += 1
  when :up
    y -= 1
  end

  if x < 0 || x > max_x || y < 0 || y > max_y
    break
  end

  case path_diagram[y][x]
  when /[A-Z]/
    output += path_diagram[y][x]
  when ' '
    break
  when '+'
    case direction
    when :down, :up
      if x == 0
        direction = :right
      elsif x == max_x
        direction = :left
      elsif path_diagram[y][x-1] != ' '
        direction = :left
      else
        direction = :right
      end
    when :left, :right
      if y == 0
        direction = :down
      elsif y == max_y
        direction = :up
      elsif path_diagram[y-1][x] != ' '
        direction = :up
      else
        direction = :down
      end
    end
  end
  steps += 1
end
puts output
puts steps
