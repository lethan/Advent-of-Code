file = File.open('../../input/2016/input_day03.txt', 'r')
input = []
while line = file.gets
  match = /\s*(\d+)\s+(\d+)\s+(\d+)/.match(line)
  input << match[1..3].map(&:to_i)
end
file.close

valid = 0
input.each do |row|
  arr = row.sort
  valid += 1 if arr[0] + arr[1] > arr[2]
end
puts valid

valid = 0
input.each_with_index do |row, index|
  if index % 3 == 2
    arr1 = [input[index-2][0], input[index-1][0], input[index][0]].sort
    arr2 = [input[index-2][1], input[index-1][1], input[index][1]].sort
    arr3 = [input[index-2][2], input[index-1][2], input[index][2]].sort
    valid += 1 if arr1[0] + arr1[1] > arr1[2]
    valid += 1 if arr2[0] + arr2[1] > arr2[2]
    valid += 1 if arr3[0] + arr3[1] > arr3[2]
  end
end
puts valid
