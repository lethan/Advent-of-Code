require './day10.rb'

used = 0
blocks = Array.new(128) { Array.new(128, 0) }

0.upto(127) do |number|
  text = "stpzcrnm-#{number}"
  input = []
  text.each_byte { |c| input << c}
  input += [17, 31, 73, 47, 23]
  hash = hex(knot_hash(input, 64), false)
  hash.each_with_index do |hash_number, index|
    string = "0" * (8 - hash_number.to_s(2).length) + hash_number.to_s(2)
    string.chars.each_with_index do |char, i|
      blocks[number][index*8+i] = char.to_i
      used += 1 if char == "1"
    end
  end
end
puts used

def make_region(region, x, y, arr)
  if x >=0 && y >= 0 && x<arr.length && y<arr[0].length
    if arr[x][y] == 1
      arr[x][y] = region
      make_region(region, x-1, y, arr)
      make_region(region, x+1, y, arr)
      make_region(region, x, y-1, arr)
      make_region(region, x, y+1, arr)
    end
  end
end

region = 1
blocks.each_with_index do |row, x|
  row.each_with_index do |block, y|
    if block == 1
      region += 1
      make_region(region, x, y, blocks)
    end
  end
end

puts region - 1
