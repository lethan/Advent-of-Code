registers = Hash.new(0)

max_value = 0
file = File.open("../../input/2017/input_day08.txt", "r")
while line = file.gets
  match = /(\S+) (inc|dec) (-?\d+) if (\S+) ([=<>!]{1,2}) (-?\d+)/.match(line)
  compute = false
  case match[5]
  when "=="
    compute = true if registers[match[4]] == match[6].to_i
  when "<"
    compute = true if registers[match[4]] < match[6].to_i
  when "<="
    compute = true if registers[match[4]] <= match[6].to_i
  when ">"
    compute = true if registers[match[4]] > match[6].to_i
  when ">="
    compute = true if registers[match[4]] >= match[6].to_i
  when "!="
    compute = true if registers[match[4]] != match[6].to_i
  else
    puts "Unknown operator: " + match[5]
  end
  if compute
    if match[2] == "dec"
      registers[match[1]] -= match[3].to_i
    end
    if match[2] == "inc"
      registers[match[1]] += match[3].to_i
    end
    max_value = registers[match[1]] if registers[match[1]] > max_value
  end
end
file.close

puts registers.max_by{|k,v| v}[1]
puts max_value
