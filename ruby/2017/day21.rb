file = File.open('../../input/2017/input_day21.txt', 'r')
enhancement_rules = Hash.new

while line = file.gets
  input, output = line.chomp.split(' => ')
  output = output.split('/')
  input = input.split('/')
  result = []
  output.each do |out|
    result << out.split('').map { |a| a == '#' }
  end
  search = []
  input.each do |inp|
    search << inp.split('').map { |a| a == '#' }
  end

  rotated = search
  0.upto(3) do
    rotated = rotated.dup
    0.upto(search.length-2) do |x|
      (x+1).upto(search.length-1) do |y|
        tmp = rotated[x][y]
        rotated[x][y] = rotated[y][x]
        rotated[y][x] = tmp
      end
    end
    rotated.each do |row|
      row.reverse!
    end
    if enhancement_rules[rotated.flatten].nil?
      enhancement_rules.merge!( rotated.flatten => result )
    end
    mirrored_horizontal = []
    rotated.each do |s|
      mirrored_horizontal << s.reverse
    end
    if enhancement_rules[mirrored_horizontal.flatten].nil?
      enhancement_rules.merge!( mirrored_horizontal.flatten => result )
    end
    mirrored_vertical = rotated.reverse
    if enhancement_rules[mirrored_vertical.flatten].nil?
      enhancement_rules.merge!( mirrored_vertical.flatten => result )
    end
  end

end

canvas = [[false, true, false], [false, false, true], [true, true, true]]

1.upto(18) do |number|
  split_size = canvas.length % 2 == 0 ? 2 : 3
  new_canvas = []
  0.upto((canvas.length-1)/split_size) do |x|
    0.upto((canvas.length-1)/split_size) do |y|
      tmp = []
      0.upto(split_size-1) do |n|
        tmp += canvas[x*split_size+n][y*split_size..(y+1)*split_size-1]
      end
      if new_canvas[x].nil?
        new_canvas[x] = []
      end
      new_canvas[x][y] = enhancement_rules[tmp].dup
    end
  end
  canvas = []
  0.upto(new_canvas.length - 1) do |y|
    0.upto(new_canvas[0][0].length - 1) do |n|
      tmp = []
      0.upto(new_canvas.length - 1) do |x|
        tmp += new_canvas[y][x][n]
      end
      canvas << tmp
    end
  end
  if number == 5
    lit = 0
    canvas.each do |line|
      line.each do |value|
        lit +=1 if value
      end
    end
    puts lit
  end
end

lit = 0
canvas.each do |line|
  line.each do |value|
    lit +=1 if value
  end
end
puts lit
