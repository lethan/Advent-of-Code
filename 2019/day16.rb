# frozen_string_literal: true

input = []
file = File.open('input_day16.txt', 'r')
while (line = file.gets)
  input = line.strip.split('').map(&:to_i)
end
file.close

def fft(input)
  input = input.clone
  100.times do
    new_input = []
    position = 0
    input.each do
      position += 1
      phase = [0] * position + [1] * position + [0] * position + [-1] * position
      phase_sum = 0
      input.each_with_index do |value, index|
        phase_sum += value * phase[(index + 1) % phase.size]
      end
      new_input << phase_sum.abs % 10
    end
    input = new_input
  end
  input
end

def fft_approx(input)
  input = input.clone
  100.times do
    new_input = input.clone
    (input.size - 2).downto(0) do |i|
      new_input[i] = (new_input[i + 1] + input[i]) % 10
    end
    input = new_input
  end
  input
end

puts fft(input)[0..7].map(&:to_s).join
offset = input[0..6].map(&:to_s).join.to_i
puts fft_approx(input * 10_000)[offset..(offset + 7)].map(&:to_s).join
