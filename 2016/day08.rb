file = File.open('input_day08.txt', 'r')
display = Array.new(6) { Array.new(50, false) }
while line = file.gets
  match = /(rect (\d+)x(\d+))|(rotate (row|column) (x|y)=(\d+) by (\d+))/.match(line)
  if match[1]
    0.upto(match[2].to_i - 1) do |x|
      0.upto(match[3].to_i - 1) do |y|
        display[y][x] = true
      end
    end
  end
  if match[4]
    if match[5] == 'row'
      row = match[7].to_i
      shift = match[8].to_i % 50
      tmp = display[row].dup
      shifting = tmp.pop(shift)
      tmp.unshift(shifting).flatten!
      tmp.each_with_index do |value, i|
        display[row][i] = value
      end
    end
    if match[5] == 'column'
      column = match[7].to_i
      shift = match[8].to_i % 6
      tmp = []
      0.upto(5) do |number|
        tmp << display[number][column]
      end
      shifting = tmp.pop(shift)
      tmp.unshift(shifting).flatten!
      tmp.each_with_index do |value, i|
        display[i][column] = value
      end
    end
  end
end
file.close

lit = 0
display.each do |row|
  row.each do |value|
    lit += 1 if value
    print value ? 'X' : ' '
  end
  print "\n"
end
puts lit
