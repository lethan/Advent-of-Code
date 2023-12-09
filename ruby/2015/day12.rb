require 'json'

file = File.open('../../input/2015/input_day12.txt', 'r')
while line = file.gets
  input = JSON.parse(line)
end
file.close

def sum(input, ignore_red=false)
  if ignore_red
    if input.is_a? Hash
      input.each do |key, value|
        return 0 if value == 'red'
      end
    end
  end

  sum = 0
  input.each do |value|
    sum += value if value.is_a? Numeric
    sum += sum(value, ignore_red) if value.respond_to?(:each)
  end
  sum
end

puts sum(input)
puts sum(input, true)
