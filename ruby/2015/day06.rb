lights = Array.new(1000) { Array.new(1000, false) }
lights2 = Array.new(1000) { Array.new(1000, 0) }

file = File.open('../../input/2015/input_day06.txt', 'r')
while line = file.gets
  match = /(toggle|turn on|turn off) (\d+),(\d+) through (\d+),(\d+)/.match(line)
  (match[2].to_i).upto(match[4].to_i) do |x|
    match[3].to_i.upto(match[5].to_i) do |y|
      case match[1]
      when "turn off"
        lights[x][y] = false
        lights2[x][y] -= 1 if lights2[x][y] > 0
      when "turn on"
        lights[x][y] = true
        lights2[x][y] += 1
      when "toggle"
        lights2[x][y] += 2
        if lights[x][y]
          lights[x][y] = false
        else
          lights[x][y] = true
        end
      end
    end
  end
end
file.close

lit = 0
lights.each do |arr|
  arr.each do |status|
    if status
      lit += 1
    end
  end
end

puts lit

brightness = 0
lights2.each do |arr|
  arr.each do |bright|
    brightness += bright
  end
end

puts brightness
