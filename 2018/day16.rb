# frozen_string_literal: true

require 'english'

def addr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] + arr[in_b]
end

def addi(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] + in_b
end

def mulr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] * arr[in_b]
end

def muli(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] * in_b
end

def banr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] & arr[in_b]
end

def bani(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] & in_b
end

def borr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] | arr[in_b]
end

def bori(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] | in_b
end

def setr(arr, in_a, _in_b, out_c)
  arr[out_c] = arr[in_a]
end

def seti(arr, in_a, _in_b, out_c)
  arr[out_c] = in_a
end

def gtir(arr, in_a, in_b, out_c)
  arr[out_c] = in_a > arr[in_b] ? 1 : 0
end

def gtri(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] > in_b ? 1 : 0
end

def gtrr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] > arr[in_b] ? 1 : 0
end

def eqir(arr, in_a, in_b, out_c)
  arr[out_c] = in_a == arr[in_b] ? 1 : 0
end

def eqri(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] == in_b ? 1 : 0
end

def eqrr(arr, in_a, in_b, out_c)
  arr[out_c] = arr[in_a] == arr[in_b] ? 1 : 0
end

def possible_operations(in_arr, out_arr, command)
  operations = %i[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr]
  possible = []
  operations.each do |op|
    new_arr = in_arr.dup
    method(op).call(new_arr, command[1], command[2], command[3])
    possible << op if out_arr == new_arr
  end
  possible
end

file = File.open('input_day16.txt', 'r')
in_sample = false
sample_op = nil
input_arr = nil
operation_array = Array.new(16) { %i[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr] }
count_of_multiple = 0
commands = []
while (line = file.gets)
  case line
  when /Before: \[(\d+), (\d+), (\d+), (\d+)\]/
    in_sample = true
    input_arr = $LAST_MATCH_INFO[1..4].map(&:to_i)
  when /^(\d+) (\d+) (\d+) (\d+)/
    if in_sample
      sample_op = $LAST_MATCH_INFO[1..4].map(&:to_i)
    else
      commands << $LAST_MATCH_INFO[1..4].map(&:to_i)
    end
  when /After:  \[(\d+), (\d+), (\d+), (\d+)\]/
    in_sample = false
    out_arr = $LAST_MATCH_INFO[1..4].map(&:to_i)
    possible_ops = possible_operations(input_arr, out_arr, sample_op)
    count_of_multiple += 1 if possible_ops.length >= 3
    operation_array[sample_op[0]] &= possible_ops
  end
end
file.close

puts count_of_multiple

last_command_count = 0
while last_command_count != operation_array.map { |a| a.is_a?(Array) ? a.length : 1 }.sum
  last_command_count = operation_array.map { |a| a.is_a?(Array) ? a.length : 1 }.sum
  operation_array.each_with_index do |outer_value, outer_index|
    next unless outer_value.is_a?(Array)
    next unless outer_value.length == 1

    operation_array.each_with_index do |inner_value, inner_index|
      operation_array[inner_index] -= outer_value if inner_value.is_a?(Array) && inner_index != outer_index
    end
    operation_array[outer_index] = outer_value.first
  end
end
registers = Array.new(4, 0)
commands.each do |command|
  method(operation_array[command[0]]).call(registers, command[1], command[2], command[3])
end
puts registers[0]
