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
  arr.length
end

arr = input.split('')
puts reduced_length(arr)

shortest_length = nil
input.split('').map(&:downcase).uniq.each do |remove|
  arr = input.split('') - [remove.downcase] - [remove.upcase]
  length = reduced_length(arr)
  shortest_length ||= length
  shortest_length = length if length < shortest_length
end
puts shortest_length
