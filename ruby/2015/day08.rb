file = File.open('../../input/2015/input_day08.txt', 'r')
code_length = 0
memory_length = 0
encoded_length = 0
while line = file.gets
  code_length += line.length - 1
  last_char_escape = 0
  subtract = 3
  line[0..-2].chars.each do |char|
    if last_char_escape == 1
      if char == "x"
        subtract += 3
      else
        subtract += 1
      end
    end
    if last_char_escape == 0
      if char == "\\"
        last_char_escape = 2
      end
    end
    last_char_escape -= 1 if last_char_escape > 0
    if char == "\"" || char == "\\"
      encoded_length += 1
    end

  end
  encoded_length += line.length + 1
  memory_length += line.length - subtract
end
file.close

puts code_length - memory_length
puts encoded_length - code_length
