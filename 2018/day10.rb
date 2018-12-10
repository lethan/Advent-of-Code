file = File.open('input_day10.txt', 'r')
points = []
while (line = file.gets)
  points << /position=<\s*(-?\d+),\s*(-?\d+)> velocity=<\s*(-?\d+),\s*(-?\d+)>/.match(line)[1..4].map(&:to_i)
end
file.close

x_minmax = points.map(&:first).minmax
area = (x_minmax[1] - x_minmax[0]).abs
y_minmax = points.map { |a| a[1] }.minmax
area += (y_minmax[1] - y_minmax[0]).abs

new_area = area

time = 0
until new_area > area
  area = new_area
  points.each do |point|
    point[0] += point[2]
    point[1] += point[3]
  end

  x_minmax = points.map(&:first).minmax
  new_area = (x_minmax[1] - x_minmax[0]).abs
  y_minmax = points.map { |a| a[1] }.minmax
  new_area += (y_minmax[1] - y_minmax[0]).abs
  time += 1
end

points.each do |point|
  point[0] -= point[2]
  point[1] -= point[3]
end

x_minmax = points.map(&:first).minmax
y_minmax = points.map { |a| a[1] }.minmax

display = Array.new( (y_minmax[1] - y_minmax[0]).abs + 1){ Array.new( (x_minmax[1] - x_minmax[0]).abs + 1, false) }

points.each do |point|
  display[ point[1] - y_minmax.first ][ point[0] - x_minmax.first ] = true
end

display.each do |out|
  puts out.map { |b| b ? '#' : ' ' }.join
end

puts time - 1
