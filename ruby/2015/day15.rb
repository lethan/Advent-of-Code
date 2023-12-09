ingredients = Hash.new

file = File.open('../../input/2015/input_day15.txt', 'r')
while line = file.gets
  match = /([a-zA-Z]+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)/.match(line)
  ingredients.merge!( match[1] => {
    capacity: match[2].to_i,
    durability: match[3].to_i,
    flavor: match[4].to_i,
    texture: match[5].to_i,
    calories: match[6].to_i
    })
end
file.close

def max_score(selectable, amounts, ingredients, current_score, energy_control=false)
  if selectable.length == amounts.length
    capacity = 0
    durability = 0
    flavor = 0
    texture = 0
    calories = 0
    selectable.each_with_index do |ingredient, index|
      capacity += ingredients[ingredient][:capacity] * amounts[index]
      durability += ingredients[ingredient][:durability] * amounts[index]
      flavor += ingredients[ingredient][:flavor] * amounts[index]
      texture += ingredients[ingredient][:texture] * amounts[index]
      calories += ingredients[ingredient][:calories] * amounts[index]
    end
    capacity = 0 if capacity < 0
    durability = 0 if durability < 0
    flavor = 0 if flavor < 0
    texture = 0 if texture < 0
    calories = 0 if calories < 0
    energy_factor = 1
    if energy_control
      energy_factor = 0 if calories != 500
    end
    score = capacity * durability * flavor * texture * energy_factor
    current_score = score if score > current_score
  end

  if amounts.length == selectable.length - 1
    value = max_score(selectable, amounts + [100 - amounts.sum], ingredients, current_score, energy_control)
    current_score = value if value > current_score
  elsif amounts.length < selectable.length - 1
    0.upto(100-amounts.sum) do |amount|
      value = max_score(selectable, amounts + [amount], ingredients, current_score, energy_control)
      current_score = value if value > current_score
    end
  end
  current_score
end

puts max_score(ingredients.keys, [], ingredients, 0)
puts max_score(ingredients.keys, [], ingredients, 0, true)
