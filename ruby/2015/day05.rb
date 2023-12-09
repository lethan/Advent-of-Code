def nice?(input)
  last_char = ""
  wovels = 0
  two_in_a_row = false
  input.split('').each do |char|
    case char
    when 'a', 'e', 'i', 'o', 'u'
      wovels += 1
    when 'b'
      return false if last_char == "a"
    when 'd'
      return false if last_char == "c"
    when 'q'
      return false if last_char == "p"
    when 'y'
      return false if last_char == "x"
    end

    two_in_a_row = true if last_char == char
    last_char = char
  end
  two_in_a_row && wovels >= 3
end

def nice2?(input)
  arr = input.split('')
  one_between = false
  two_alike = false
  arr.each_with_index do |char, index|
    one_between = true if char == arr[index+2]
    if !two_alike
      (index+2).upto(arr.length-2).each do |number|
        two_alike = true if char == arr[number] && arr[index+1] == arr[number+1]
      end
    end
  end
  one_between && two_alike
end

file = File.open('input_day05.txt', 'r')
nice = 0
nice2 = 0
while line = file.gets
  nice += 1 if nice?(line)
  nice2 +=1 if nice2?(line)
end
file.close

puts nice
puts nice2
