# frozen_string_literal: true

file = File.open('input_day01.txt', 'r')
weights = []
while (line = file.gets)
  weights << line.strip.to_i
end
file.close

def fuel_weight(weight, include_fuel_weight = false)
  fuel = [0, weight / 3 - 2].max
  if include_fuel_weight
    fuel += fuel_weight(fuel, include_fuel_weight) unless fuel.zero?
  end
  fuel
end

puts weights.map { |n| fuel_weight(n) }.reduce(:+)

puts weights.map { |n| fuel_weight(n, true) }.reduce(:+)
