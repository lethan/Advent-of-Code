# frozen_string_literal: true

require_relative 'intcode'

program = []
file = File.open('../../input/2019/input_day23.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

network = []
input_queue = []
(0..49).each do |computer|
  network[computer] = Program.new(program).input(computer)
  input_queue[computer] = []
end

first_nat = true
sent_twice = nil
last_sent = nil
nat_x = nil
nat_y = nil
idle_network = true
until sent_twice
  idle_network = true
  (0..49).each do |computer|
    if input_queue[computer].empty?
      network[computer].input(-1)
    else
      idle_network = false
      while (value = input_queue[computer].shift)
        network[computer].input(value)
      end
    end
    while network[computer].outputs?
      idle_network = false
      address = network[computer].output
      x = network[computer].output
      y = network[computer].output
      if address == 255
        if first_nat
          puts y
          first_nat = false
        end
        nat_x = x
        nat_y = y
      else
        input_queue[address] << x << y
      end
    end
  end
  next unless idle_network

  input_queue[0] << nat_x << nat_y
  sent_twice = nat_y if nat_y == last_sent
  last_sent = nat_y
end
puts sent_twice
