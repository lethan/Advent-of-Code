input = ""
file = File.open('input_day02.txt', 'r')
while line = file.gets
  input += line
end
file.close

def diff(arr)
  min = -1
  max = -1
  arr.each do |number|
    min = number if number < min || min == -1
    max = number if number > max
  end
  max - min
end

def div(arr)
  length = arr.length - 1
  arr.each_with_index do |number, index|
    (index+1 .. length).each do |x|
      return number/arr[x] if number % arr[x] == 0
      return arr[x]/number if arr[x] % number == 0
    end
  end
end

def checksum(arr, type = 0)
  input = arr.split("\n")
  sum = 0
  input.each do |row|
    if type == 0
      sum += diff(row.split(' ').map(&:to_i))
    else
      sum += div(row.split(' ').map(&:to_i))
    end
  end
  sum
end

puts checksum(input)
puts checksum(input, 1)
