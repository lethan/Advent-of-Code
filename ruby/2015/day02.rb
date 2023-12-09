file = File.open("../../input/2015/input_day02.txt", "r")

area = 0
ribbon = 0
while line = file.gets
  line = line.split('x').map(&:to_i).sort
  area += 2*line[0]*line[1] + 2*line[0]*line[2] + 2*line[1]*line[2] + line[0]*line[1]
  ribbon += 2*line[0] + 2*line[1] + line[0]*line[1]*line[2]
end
file.close

puts area
puts ribbon
