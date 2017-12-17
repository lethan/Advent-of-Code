input = ""
file = File.open('input_day04.txt', 'r')
while line = file.gets
  input += line
end
file.close

def valid_password(input, type=0)
  words = input.split(' ')
  if type == 1
    words = words.map { |word| word.chars.sort.join }
  end
  words.sort!
  last_password = ''
  words.each do |word|
    return false if word == last_password
    last_password = word
  end
  return true
end

def number_valid(input, type = 0)
  passwords = input.split("\n")
  valid_password = 0
  passwords.each do |password|
    valid_password += 1 if valid_password(password, type)
  end
  valid_password
end

puts number_valid(input)
puts number_valid(input, 1)
