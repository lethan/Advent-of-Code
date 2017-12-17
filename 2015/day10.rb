input = "1113222113"

1.upto(50) do |number|
  last_char = "-"
  count = 1
  new_input = ""
  input.chars.each do |char|
    if char != last_char
      if last_char != "-"
        new_input += "#{count}#{last_char}"
      end
      last_char = char
      count = 1
    else
      count += 1
    end
  end
  new_input += "#{count}#{last_char}"
  input = new_input
  if number == 40
    puts input.length
  end
end

puts input.length
