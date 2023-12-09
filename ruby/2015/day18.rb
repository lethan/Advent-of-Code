file = File.open('input_day18.txt', 'r')
all_lights = []
while line =file.gets
  lights = []
  line.split('').each do |char|
    if char == '.'
      lights << false
    end
    if char == '#'
      lights << true
    end
  end
  all_lights << lights
end
file.close

def lit(input, failed=false)
  input = input.dup
  if failed
    input[0][0] = true
    input[0][99] = true
    input[99][0] = true
    input[99][99] = true
  end
  1.upto(100) do
    new_lights = Array.new(100) { Array.new(100, false) }
    input.each_with_index do |line, x|
      line.each_with_index do |light, y|
        neighbors_on = 0
        (x-1).upto(x+1) do |xx|
          (y-1).upto(y+1) do |yy|
            if xx >= 0 && xx < input.length && yy >= 0 && yy < line.length
              if xx != x || yy != y
                neighbors_on += 1 if input[xx][yy]
              end
            end
          end
        end
        if neighbors_on == 3
          new_lights[x][y] = true
        end
        if neighbors_on == 2 && light
          new_lights[x][y] = true
        end
      end
    end
    input = new_lights
    if failed
      input[0][0] = true
      input[0][99] = true
      input[99][0] = true
      input[99][99] = true
    end
  end

  lit = 0
  input.each do |line|
    line.each do |light|
      lit += 1 if light
    end
  end
  lit
end

puts lit(all_lights)
puts lit(all_lights, true)
