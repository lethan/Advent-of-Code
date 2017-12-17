input = [14, 0, 15, 12, 11, 11, 3, 5, 1, 6, 8, 4, 9, 1, 8, 4]

def cycles(input,part=1)
  seen = Array.new
  seen << input
  steps = 0
  working = input.dup
  while true do
    steps += 1
    max = 0
    max_index = 0
    working.each_with_index do |number, index|
      if number > max
        max = number
        max_index = index
      end
    end
    working[max_index] = 0
    index = max_index + 1
    while max > 0 do
      working[index % working.length] += 1
      index += 1
      max -= 1
    end
    seen << working
    break if seen.group_by{ |e| e }.select { |k, v| v.size > 1 }.map(&:first) != []
    working = working.dup
  end
  steps - (part==2 ? seen.find_index(working) : 0)
end

puts cycles(input)
puts cycles(input, 2)
