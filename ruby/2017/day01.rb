file = File.open('../../input/2017/input_day01.txt', 'r')
input = ""
while line = file.gets
  input += line.strip
end
file.close

def inverse_captcha(input, skip = 1)
  sum = 0
  numbers = input.split('').map(&:to_i)
  numbers.each_with_index do |number, index|
    sum += number if number == numbers[(index + skip) % numbers.length]
  end
  sum
end

puts inverse_captcha(input)
puts inverse_captcha(input, input.length / 2)
