# frozen_string_literal: true

file = File.open('input_day18.txt', 'r')
forrest = []
while (line = file.gets)
  forrest << line.chomp.split('')
end
file.close

def resouces(period, forrest)
  seen_forrests = {}
  count = 0
  seen_forrests[forrest] = count
  while count < period
    new_forrest = []
    forrest.each_with_index do |row, forrest_y|
      new_row = []
      row.each_with_index do |acre, forrest_x|
        new_acre = acre
        trees = 0
        lumberyards = 0
        -1.upto(1) do |x|
          -1.upto(1) do |y|
            next if x.zero? && y.zero?

            next_x = forrest_x + x
            next if next_x.negative? || next_x >= row.length

            next_y = forrest_y + y
            next if next_y.negative? || next_y >= forrest.length

            trees += 1 if forrest[next_y][next_x] == '|'
            lumberyards += 1 if forrest[next_y][next_x] == '#'
          end
        end
        new_acre = '|' if acre == '.' && trees >= 3
        new_acre = '#' if acre == '|' && lumberyards >= 3
        if acre == '#'
          new_acre = '.' unless trees >= 1 && lumberyards >= 1
        end
        new_row << new_acre
      end
      new_forrest << new_row
    end
    forrest = new_forrest
    count += 1
    if seen_forrests[forrest]
      step_size = count - seen_forrests[forrest]
      steps = (period - count) / step_size
      count += steps * step_size
      seen_forrests = {}
    end
    seen_forrests[forrest] = count
  end
  forrest.flatten.count('|') * forrest.flatten.count('#')
end

puts resouces(10, forrest.dup)
puts resouces(1_000_000_000, forrest.dup)
