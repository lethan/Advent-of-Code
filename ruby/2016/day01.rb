file = File.open('../../input/2016/input_day01.txt', 'r')
input = []
while line = file.gets
  input += line.chomp.split(', ')
end
file.close

x = 0
y = 0
visited = Hash.new
visited.merge!( { 0 => Hash.new } )
visited[0].merge!( {0 => true} )
first_visited = nil
direction = :north

input.each do |val|
  _, turn, steps = /(R|L)(\d+)/.match(val).to_a
  steps = steps.to_i
  case direction
  when :north
    if turn == 'L'
      direction = :west
    elsif turn == 'R'
      direction = :east
    end
  when :south
    if turn == 'L'
      direction = :east
    elsif turn == 'R'
      direction = :west
    end
  when :east
    if turn == 'L'
      direction = :north
    elsif turn == 'R'
      direction = :south
    end
  when :west
    if turn == 'L'
      direction = :south
    elsif turn == 'R'
      direction = :north
    end
  end

  case direction
  when :north
    (y+1).upto(y+steps) do |yy|
      if visited.dig(x, yy) && first_visited.nil?
        first_visited = [x, yy]
      end
      if visited[x].nil?
        visited.merge!( {x => Hash.new })
      end
      visited[x].merge!( {yy => true} )
    end
    y += steps
  when :south
    (y-1).upto(y-steps) do |yy|
      if visited.dig(x, yy) && first_visited.nil?
        first_visited = [x, yy]
      end
      if visited[x].nil?
        visited.merge!( {x => Hash.new })
      end
      visited[x].merge!( {yy => true} )
    end
    y -= steps
  when :east
    (x+1).upto(x+steps) do |xx|
      if visited.dig(xx, y) && first_visited.nil?
        first_visited = [xx, y]
      end
      if visited[xx].nil?
        visited.merge!( {xx => Hash.new })
      end
      visited[xx].merge!( {y => true} )
    end
    x += steps
  when :west
    (x-1).upto(x-steps) do |xx|
      if visited.dig(xx, y) && first_visited.nil?
        first_visited = [xx, y]
      end
      if visited[xx].nil?
        visited.merge!( {xx => Hash.new })
      end
      visited[xx].merge!( {y => true} )
    end
    x -= steps
  end
end

puts x.abs + y.abs
puts first_visited.map(&:abs).sum
