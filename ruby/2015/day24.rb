file = File.open('input_day24.txt', 'r')
packets = []
while line = file.gets
  packets << line.to_i
end
file.close

def valid_group?(input, weight, level)
  number = 0
  while true
    result = input.combination(number).to_a.reject { |a| a.sum != weight }
    if !result.empty?
      return true if level <= 0
      result.each do |group|
        new_group = input - group
        status = valid_group?(new_group, weight, level - 1)
        return true if status
      end
    end
    number += 1
    break if number > input.length
  end
  false
end

def quantum_entanglement(input, groups)
  total_weight = input.sum
  weight_pr_group = total_weight / groups

  number = 0
  first_group = []

  not_found = true
  while not_found
    result = input.combination(number).to_a.reject { |a| a.sum != weight_pr_group }.sort_by { |a| a.reduce(1, :*) }
    if !result.empty?
      result.each do |group|
        if not_found
          available_weigths = input - group
          if valid_group?(available_weigths, weight_pr_group, groups - 3)
            not_found = false
            first_group = group
          end
        end
        break if !not_found
      end
    end
    number += 1
    break if number > input.length
  end

  first_group.reduce(1, :*)
end

puts quantum_entanglement(packets, 3)
puts quantum_entanglement(packets, 4)
