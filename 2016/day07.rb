file = File.open('input_day07.txt', 'r')
valid_tls = 0
valid_ssl = 0

while line = file.gets
  input = line.chomp.split('')
  last1 = nil
  last2 = nil
  last3 = nil
  in_subnet = false
  subnet_valid = true
  address_valid = false
  aba = []
  bab = []
  input.each do |char|
    if char == '['
      last1 = nil
      last2 = nil
      last3 = nil
      in_subnet = true
    end
    if char == ']'
      last1 = nil
      last2 = nil
      last3 = nil
      in_subnet = false
    end
    if !last2.nil? && char == last2 && char != last1
      if in_subnet
        bab << last1 + char + last1
      else
        aba << char + last1 + last2
      end
    end
    if !last3.nil? && char == last3 && last2 == last1 && char != last1
      if in_subnet
        subnet_valid = false
      else
        address_valid = true
      end
    end
    last3 = last2
    last2 = last1
    last1 = char
  end
  valid_tls += 1 if address_valid && subnet_valid
  valid_ssl += 1 if !(aba & bab).empty?
end
file.close

puts valid_tls
puts valid_ssl
