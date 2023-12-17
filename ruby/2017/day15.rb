input_a = 679
input_b = 771

factor_a = 16807
factor_b = 48271
modulator = 2147483647

a = input_a
b = input_b
matches = 0
1.upto(40_000_000) do
  a = a * factor_a % modulator
  b = b * factor_b % modulator
  matches += 1 if a % 65_536 == b % 65_536
end

puts matches

a = input_a
b = input_b

matches = 0
1.upto(5_000_000) do
  looking = true
  while looking do
    a = a * factor_a % modulator
    looking = false if a % 4 == 0
  end
  looking = true
  while looking do
    b = b * factor_b % modulator
    looking = false if b % 8 == 0
  end
  matches += 1 if a % 65_536 == b % 65_536
end

puts matches
