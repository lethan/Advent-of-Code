file = File.open('../../input/2016/input_day09.txt', 'r')
input = []
while line = file.gets
  input += line.chomp.split('')
end
file.close

def decompress(input, with_recursion=false)
  decompressed_length = 0
  looking_count = 0
  looking = []
  inside_marker = false
  marker_first = true
  marker_count = 0
  input.each do |char|
    if looking_count == 0
      if inside_marker
        if marker_first
          if char == 'x'
            marker_first = false
            marker_count = looking.join.to_i
            looking = []
          else
            looking << char
          end
        else
          if char == ')'
            marker_first = true
            looking_count = marker_count
            marker_count = looking.join.to_i
            looking = []
            inside_marker = false
          else
            looking << char
          end
        end
      else
        if char == '('
          inside_marker = true
        else
          decompressed_length += 1
        end
      end
    else
      looking << char
      looking_count -= 1
      if looking_count == 0
        decompressed_length += looking.length * marker_count if !with_recursion
        decompressed_length += decompress(looking, with_recursion) * marker_count if with_recursion
        looking = []
      end
    end
  end
  decompressed_length
end

puts decompress(input)
puts decompress(input,true)
