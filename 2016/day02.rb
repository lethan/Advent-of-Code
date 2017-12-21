keypad = [['1','2','3'],
          ['4','5','6'],
          ['7','8','9']]

file = File.open('input_day02.txt', 'r')
input = []
while line = file.gets
  input << line.chomp.split('')
end
file.close

def code(input, keypad, x, y)
  keypress = []
  input.each do |line|
    line.each do |char|
      case char
      when 'D'
        y += 1 if y < keypad.length - 1 && keypad[y+1][x] != nil
      when 'U'
        y -= 1 if y > 0 && keypad[y-1][x] != nil
      when 'L'
        x -= 1 if x > 0 && keypad[y][x-1] != nil
      when 'R'
        x += 1 if x < keypad[0].length - 1 && keypad[y][x+1] != nil
      end
    end
    keypress << keypad[y][x]
  end
  keypress.join
end

puts code(input, keypad, 1, 1)

keypad = [[nil, nil, '1', nil, nil],
          [nil, '2', '3', '4', nil],
          ['5', '6', '7', '8', '9'],
          [nil, 'A', 'B', 'C', nil],
          [nil, nil, 'D', nil, nil]]

puts code(input, keypad, 0, 2)
