def knot_hash(input, iterations = 1)
  list = Array(0..255)
  current_position = 0
  skip_size = 0

  1.upto(iterations) do
    input.each do |length|
      0.upto((length-1) / 2) do |n|
        tmp = list[(current_position + n) % list.length]
        list[(current_position + n) % list.length] = list[(current_position + length - 1 - n) % list.length]
        list[(current_position + length - 1 - n) % list.length] = tmp
      end
      current_position = (current_position + length + skip_size) % list.length
      skip_size += 1
    end
  end
  list
end

def hex(input, text = true)
  result = []
  0.upto(15) do |number|
    result << input[number*(input.length/16)..(number+1)*(input.length/16)-1].inject(:^)
  end
  return result if !text
  hash = ""
  result.each do |number|
    hash += "%02x" % number
  end
  hash
end

input = [187,254,0,81,169,219,1,190,19,102,255,56,46,32,2,216]
result = knot_hash(input)
puts result[0] * result[1]

text = "187,254,0,81,169,219,1,190,19,102,255,56,46,32,2,216"
input = []
text.each_byte { |c| input << c}
input += [17, 31, 73, 47, 23]
puts hex(knot_hash(input, 64))
