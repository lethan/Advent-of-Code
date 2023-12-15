input = 3_014_387

elfs = (1..input).to_a
while elfs.length > 1
  remove_first = elfs.length.odd?
  elfs = elfs.select.with_index { |_, i| i.even? }
  elfs.delete_at(0) if remove_first
end
puts elfs.first

half_one = []
half_two = []

input.times do |i|
  if i < input / 2
    half_one << i + 1
  else
    half_two << i + 1
  end
end

while half_one.size + half_two.size > 1
  current_elf = half_one.shift

  if half_one.length == half_two.length
    half_one.pop
  else
    half_two.shift
  end

  half_two << current_elf
  half_one << half_two.shift
end

puts half_one.first
