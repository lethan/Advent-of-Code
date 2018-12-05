file = File.open('input_day05.txt', 'r')
input = ''
while (line = file.gets)
  input += line.strip
end
file.close

def reduced_length(arr)
  counter = 0
  while counter < arr.length - 1
    if (arr[counter] == arr[counter + 1].downcase && arr[counter].upcase == arr[counter + 1]) ||
       (arr[counter].downcase == arr[counter + 1] && arr[counter] == arr[counter + 1].upcase)

      arr.slice!(counter, 2)
      counter -= 1
      counter = 0 if counter < 0
    else
      counter += 1
    end
  end
  [arr.length, arr]
end

arr = input.split('')
result = reduced_length(arr)
puts result[0]

shortest_length = nil
result[1].map(&:downcase).uniq.each do |remove|
  arr = result[1] - [remove.downcase] - [remove.upcase]
  length = reduced_length(arr)[0]
  shortest_length ||= length
  shortest_length = length if length < shortest_length
end
puts shortest_length
