file = File.open('../../input/2017/input_day24.txt', 'r')
input = []
while line = file.gets
  input << line.split('/').map(&:to_i)
end
file.close

def strongest_bridge(available_components, selected_components, next_port, strongest)
  available_components.each_with_index do |component, index|
    if component.include?(next_port)
      components = available_components.dup
      components.delete_at(index)
      new_port = component[0] == next_port ? component[1] : component[0]
      value = strongest_bridge(components, selected_components + [component], new_port, strongest)
      strongest = value if value > strongest
    end
  end
  value = 0
  selected_components.each do |component|
    value += component.sum
  end
  strongest = value if value > strongest
  strongest
end

def longest_bridge(available_components, selected_components, next_port, longest, longest_value)
  available_components.each_with_index do |component, index|
    if component.include?(next_port)
      components = available_components.dup
      components.delete_at(index)
      new_port = component[0] == next_port ? component[1] : component[0]
      value1, value2 = longest_bridge(components, selected_components + [component], new_port, longest, longest_value)
      if value1 == longest
        longest_value = value2 if value2 > longest_value
      end
      if value1 > longest
        longest = value1
        longest_value = value2
      end
    end
  end
  if selected_components.length == longest
    value = strongest_bridge([], selected_components, 0, 0)
    longest_value = value if value > longest_value
  end
  if selected_components.length > longest
    longest = selected_components.length
    longest_value = strongest_bridge([], selected_components, 0, 0)
  end
  [longest, longest_value]
end

puts strongest_bridge(input, [], 0, 0)
puts longest_bridge(input, [], 0, 0, 0)[1]
