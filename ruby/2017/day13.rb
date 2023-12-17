file = File.open('../../input/2017/input_day13.txt', 'r')
firewall = Hash.new(0)
while line = file.gets
  arr = line.split(': ')
  firewall[arr[0].to_i] = arr[1].to_i
end
file.close

not_found = true
delay = -1

while not_found
  delay += 1
  severity = 0
  ok = true
  0.upto(firewall.keys.max) do |number|
    if firewall[number] > 0
      step = firewall[number] - 1
      direction = (number+delay) / step % 2
      if direction == 0
        if (number+delay) % step == 0
          severity += firewall[number] * number
          ok = false
        end
      end
    end
  end
  if delay == 0
    puts severity
  end
  if ok
    not_found = false
  end
end

puts delay
