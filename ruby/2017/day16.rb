dance_line = (0..15).to_a.map! { |a| (a+97).chr }

input = []
file = File.open('../../input/2017/input_day16.txt', 'r')
while line = file.gets
  input += line.split(',')
end
file.close

swap_table = []
swap_table[0] = (0..dance_line.length-1).to_a.map! { |a| (a+97).chr }
found_duplicate = false

itteration = 1
while !found_duplicate
  first_index = 0
  input.each do |move|
    if move[0] == "s"
      first_index = (first_index + dance_line.length - move[1..-1].to_i) % dance_line.length
    end
    if move[0] == "x"
      match = /^x(\d+)\/(\d+)/.match(move)
      a = (match[1].to_i + first_index) % dance_line.length
      b = (match[2].to_i + first_index) % dance_line.length
      dance_line[a], dance_line[b] = dance_line[b], dance_line[a]
    end
    if move[0] == "p"
      match = /^p([a-z])\/([a-z])/.match(move)
      a = dance_line.index(match[1])
      b = dance_line.index(match[2])
      dance_line[a], dance_line[b] = dance_line[b], dance_line[a]
    end
  end

  dance_line = dance_line[first_index..(dance_line.length-1)] + dance_line[0..(first_index-1)]
  if swap_table.detect { |e| e == dance_line }
    found_duplicate = true
  end
  swap_table[itteration] = dance_line.dup
  itteration += 1
end

string = swap_table[1].join
puts string

itterations = 1_000_000_000
start_period = swap_table.index(swap_table.last)
end_period = swap_table.length - 1
period = end_period - start_period
itterations -= start_period
string = swap_table[itterations % period + start_period].join

puts string
