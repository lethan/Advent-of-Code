file = File.open('../../input/2016/input_day06.txt', 'r')
chars = []
while line = file.gets
  line = line.chomp.split('')
  if chars.empty?
    chars = Array.new(line.length) { Array.new }
  end
  line.each_with_index do |v, i|
    chars[i] << v
  end
end
file.close
signal = []
signal2 = []
chars.each do |chrs|
  sorted = chrs.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| -v }
  signal << sorted.first[0]
  signal2 << sorted.last[0]
end
puts signal.join
puts signal2.join
