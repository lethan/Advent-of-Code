input = 768_071

recipes = [3, 7]
current_ending = recipes.dup
elf1 = 0
elf2 = 1
ending = input.to_s.split('').map(&:to_i)
run = true
printed_ten_after = false
while run || !printed_ten_after
  value1 = recipes[elf1]
  value2 = recipes[elf2]
  new_recipe = value1 + value2
  if (new_recipe / 10).positive?
    recipes << new_recipe / 10
    current_ending << new_recipe / 10
    current_ending.shift if current_ending.length > ending.length
    if run && current_ending == ending
      puts "Part Two: #{recipes.length - ending.length}"
      run = false
    end
  end
  recipes << new_recipe % 10
  current_ending << new_recipe % 10
  current_ending.shift if current_ending.length > ending.length
  if run && current_ending == ending
    puts "Part Two: #{recipes.length - ending.length}"
    run = false
  end
  elf1 = (elf1 + 1 + recipes[elf1]) % recipes.length
  elf2 = (elf2 + 1 + recipes[elf2]) % recipes.length
  if !printed_ten_after && recipes.length >= input + 10
    puts "Part One: #{recipes[input, 10].map(&:to_s).join}"
    printed_ten_after = true
  end
end
