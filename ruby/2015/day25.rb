file = File.open('../../input/2015/input_day25.txt', 'r')
row = 0
column = 0
while line = file.gets
  match = /Enter the code at row (\d+), column (\d+)\./.match(line)
  if match
    column = match[1].to_i
    row = match[2].to_i
  end
end
file.close

def position(column, row)
  start_column = 1
  steps_after_start = column - start_column
  start_row = row + steps_after_start
  start_number = 0
  1.upto(start_row) do |number|
    start_number += number
  end
  start_number - steps_after_start
end

current_value = 20151125
code_position = position(column, row)
2.upto(code_position) do
  current_value *= 252533
  current_value %= 33554393
end
puts current_value
