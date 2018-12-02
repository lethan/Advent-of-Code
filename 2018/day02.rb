file = File.open('input_day02.txt', 'r')
id_codes = []
while line = file.gets
   id_codes << line.strip
end
file.close

twos = 0
threes = 0
id_codes.each do |code|
  two_found = false
  three_found = false
  code.split('').inject(Hash.new(0)) { |total, e| total[e] += 1 ;total}.each do |_, val|
    two_found = true if val == 2
    three_found = true if val == 3
  end
  twos += 1 if two_found
  threes += 1 if three_found
end
puts twos * threes

found_result = false
while current = id_codes.pop
  break if found_result
  id_codes.each do |code|
    break if found_result
    diffs = 0
    common = ''
    new_code = code.split('')
    current.split('').each_with_index do |value, index|
      diffs += 1 if value != new_code[index]
      common += value if value == new_code[index]
      break if diffs > 1
    end
    if diffs == 1
      puts common
      found_result = true
    end
  end
end

