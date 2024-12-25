# frozen_string_literal: true

reactions = {}
file = File.open('../../input/2019/input_day14.txt', 'r')
while (line = file.gets)
  in_out = line.strip.split(' => ')
  result = in_out.last
  amount, material = result.split
  amount = amount.to_i
  reactions[material] = { out_amount: amount, input: [] }
  in_out.first.split(', ').each do |input|
    amount, in_material = input.split
    amount = amount.to_i
    reactions[material][:input] << [in_material, amount]
  end
end
file.close

def required_materials(reactions, needed = { 'FUEL' => 1 })
  changes = false
  needed['ORE'] = 0 if needed['ORE'].nil?
  reactions.keys.each { |m| needed[m] = 0 if needed[m].nil? }

  needed.each_pair do |material, amount|
    next if amount <= 0
    next unless reactions[material]

    changes = true
    qoutient = (reactions[material][:out_amount] + amount - 1) / reactions[material][:out_amount]
    reactions[material][:input].each do |input|
      needed[input[0]] += input[1] * qoutient
    end
    needed[material] -= reactions[material][:out_amount] * qoutient
  end
  needed = required_materials(reactions, needed) if changes
  needed
end

ore_from_one_fuel = required_materials(reactions)['ORE']
puts ore_from_one_fuel

ore_amount = 1_000_000_000_000
high = ore_amount / ore_from_one_fuel * 2
low = ore_amount / ore_from_one_fuel / 2
while high != low
  mid = (high + low) / 2
  ore_needed = required_materials(reactions, 'FUEL' => mid)['ORE']
  if ore_needed > ore_amount
    high = mid - 1
  else
    low = mid
  end
end
puts high
