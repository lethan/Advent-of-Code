file = File.open('input_day09.txt', 'r')
distances = Hash.new

while line = file.gets
  match = /([a-zA-Z]+) to ([a-zA-Z]+) = ([0-9]+)/.match(line)
  if distances[match[1]].nil?
    distances.merge!( match[1] => Hash.new )
  end
  if distances[match[2]].nil?
    distances.merge!( match[2] => Hash.new )
  end
  distances[match[1]].merge!(match[2] => match[3].to_i)
  distances[match[2]].merge!( match[1] => match[3].to_i )
end
file.close

def minmax_distance(selectable, selected, distances, current_value, min=true)
  if selectable.empty?
    distance = 0
    last_place = selected.shift
    selected.each do |place|
      distance += distances[last_place][place]
      last_place = place
    end
    if min
      current_value = distance if distance < current_value || current_value < 0
    else
      current_value = distance if distance > current_value
    end
  end
  selectable.each do |select|
    value = minmax_distance(selectable - [select], selected + [select], distances, current_value, min)
    if min
      current_value = value if value < current_value || current_value < 0
    else
      current_value = value if value > current_value
    end
  end
  current_value
end

puts minmax_distance(distances.keys, [], distances, -1)
puts minmax_distance(distances.keys, [], distances, -1, false)
