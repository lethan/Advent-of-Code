ticker = {children: 3, cats: 7, samoyeds: 2, pomeranians: 3, akitas: 0, vizslas: 0, goldfish: 5, trees: 3, cars: 2, perfumes: 1}

file = File.open('input_day16.txt', 'r')
input = []
while line = file.gets
  input << line
end
file.close

input.each do |line|
  match = /Sue (\d+): (.*)/.match(line)
  sue_number = match[1].to_i
  information = match[2]
  valid_sue = true
  information.split(', ').each do |info|
    type, amount = info.split(': ')
    if ticker[type.to_sym] != amount.to_i
      valid_sue = false
      break
    end
  end
  if valid_sue
    puts sue_number
  end
end

input.each do |line|
  match = /Sue (\d+): (.*)/.match(line)
  sue_number = match[1].to_i
  information = match[2]
  valid_sue = true
  information.split(', ').each do |info|
    type, amount = info.split(': ')
    case type.to_sym
    when :cats, :trees
      if ticker[type.to_sym] >= amount.to_i
        valid_sue = false
      end
    when :pomeranians, :goldfish
      if ticker[type.to_sym] <= amount.to_i
        valid_sue = false
      end
    else
      if ticker[type.to_sym] != amount.to_i
        valid_sue = false
      end
    end
  end
  if valid_sue
    puts sue_number
  end
end
