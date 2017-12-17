file = File.open('input_day13.txt', 'r')
happiness_index = Hash.new
while line = file.gets
  match = /([a-zA-Z]+) would (gain|lose) (\d+) happiness units by sitting next to ([a-zA-Z]+)./.match(line)
  if happiness_index[match[1]].nil?
    happiness_index.merge!( match[1] => Hash.new )
  end
  happiness_index[match[1]].merge!(match[4] => (match[2] == "gain" ? 1 : -1) * match[3].to_i)
end
file.close

def max_happiness(selectable, selected, happiness_index, current_value)
  if selectable.empty?
    happiness = 0
    last_place = selected.shift
    happiness += happiness_index[last_place][selected.last]
    happiness += happiness_index[selected.last][last_place]
    selected.each do |place|
      happiness += happiness_index[last_place][place]
      happiness += happiness_index[place][last_place]
      last_place = place
    end
    current_value = happiness if happiness > current_value
  end
  selectable.each do |select|
    value = max_happiness(selectable - [select], selected + [select], happiness_index, current_value)
    current_value = value if value > current_value
  end
  current_value
end

puts max_happiness(happiness_index.keys, [], happiness_index, -10000 * 2 * happiness_index.length)
happiness_index.merge!( "Me" => Hash.new )
happiness_index.keys.each do |value|
  happiness_index["Me"].merge!( value => 0 )
  happiness_index[value].merge!( "Me" => 0 )
end
puts max_happiness(happiness_index.keys, [], happiness_index, -10000 * 2 * happiness_index.length)
