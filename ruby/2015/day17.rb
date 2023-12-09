file = File.open('../../input/2015/input_day17.txt', 'r')
containers = []
while line = file.gets
  containers << line.to_i
end
file.close
containers.sort!.reverse!

def combinations(input, selected, counter=0)
  if input.length == selected.length
    sum = 0
    selected.each_with_index do |inc, index|
      if inc
        sum += input[index]
      end
    end
    if sum == 150
      if counter > 0
        return counter == selected.count(true) ? 1 : 0
      else
        return 1
      end
    else
      return 0
    end
  end

  return combinations(input, selected + [true], counter) + combinations(input, selected + [false], counter)
end

puts combinations(containers, [])

def min_containers(input, selected, minimum)
  if input.length == selected.length
    sum = 0
    selected.each_with_index do |inc, index|
      if inc
        sum += input[index]
      end
    end
    if sum == 150
      count = selected.count(true)
      minimum = count if count < minimum
    end
  else
    value = min_containers(input, selected + [true], minimum)
    minimum = value if value < minimum
    value = min_containers(input, selected + [false], minimum)
    minimum = value if value < minimum
  end

  minimum
end

puts combinations(containers, [], min_containers(containers, [], containers.length))
