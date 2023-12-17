file = File.open('../../input/2017/input_day22.txt', 'r')
input = []
while line = file.gets
  input << line.chomp.split('')
end
file.close

infection_table = Hash.new(false)
advanced_infection_table = Hash.new(:clean)

input.each_with_index do |row, y|
  row.each_with_index do |char, x|
    infection_table[[x - ((input[0].length + 1)/2 - 1), y - ((input.length + 1) / 2 -1)]] = char == '#'
    advanced_infection_table[[x - ((input[0].length + 1)/2 - 1), y - ((input.length + 1) / 2 -1)]] = char == '#' ? :infected : :clean
  end
end
x = 0
y = 0
direction = :up
infections = 0
1.upto(10_000) do
  if infection_table[[x,y]]
    case direction
    when :up
      direction = :right
    when :down
      direction = :left
    when :right
      direction = :down
    when :left
      direction = :up
    end
    infection_table[[x,y]] = false
  else
    case direction
    when :up
      direction = :left
    when :down
      direction = :right
    when :right
      direction = :up
    when :left
      direction = :down
    end
    infections += 1
    infection_table[[x,y]] = true
  end
  case direction
  when :up
    y -= 1
  when :down
    y += 1
  when :right
    x += 1
  when :left
    x -= 1
  end
end

puts infections

infections = 0
direction = :up
x = 0
y = 0
1.upto(10_000_000) do
  if advanced_infection_table[[x,y]] == :infected
    case direction
    when :up
      direction = :right
    when :down
      direction = :left
    when :right
      direction = :down
    when :left
      direction = :up
    end
    advanced_infection_table[[x,y]] =:flagged
  elsif advanced_infection_table[[x,y]] == :clean
    case direction
    when :up
      direction = :left
    when :down
      direction = :right
    when :right
      direction = :up
    when :left
      direction = :down
    end
    advanced_infection_table[[x,y]] = :weakend
  elsif advanced_infection_table[[x,y]] == :flagged
    case direction
    when :up
      direction = :down
    when :down
      direction = :up
    when :right
      direction = :left
    when :left
      direction = :right
    end
    advanced_infection_table[[x,y]] = :clean
  elsif advanced_infection_table[[x,y]] == :weakend
    advanced_infection_table[[x,y]] = :infected
    infections += 1
  end

  case direction
  when :up
    y -= 1
  when :down
    y += 1
  when :right
    x += 1
  when :left
    x -= 1
  end
end
puts infections
