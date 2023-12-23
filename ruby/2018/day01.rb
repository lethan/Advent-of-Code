file = File.open('../../input/2018/input_day01.txt', 'r')
changes = []
while line = file.gets
   changes << line.strip.to_i
end
file.close
puts changes.sum

seen = Hash.new(false)
counter = 0
frequency = 0
while not seen[frequency]
  seen[frequency] = true
  frequency += changes[counter % changes.length]
  counter += 1
end
puts frequency
