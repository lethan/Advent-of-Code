input = '10011111011011001'

def checksum(input, disk_size)
  until input.length >= disk_size
    b = input.reverse
    b = b.chars.map { |c| c == '0' ? '1' : '0' }.join
    input = input + '0' + b
  end

  checksum = input[0..disk_size - 1]

  checksum = checksum.scan(/.{2}/).map { |i| %w[11 00].include?(i) ? '1' : '0' }.join until checksum.length.odd?
  checksum
end

puts checksum(input, 272)
puts checksum(input, 35_651_584)
