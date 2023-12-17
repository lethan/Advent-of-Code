class State
  attr_accessor :name
  attr_accessor :write_if_zero, :move_if_zero, :next_state_if_zero
  attr_accessor :write_if_one, :move_if_one, :next_state_if_one

  def initialize(name)
    @name = name
  end

  def perform(tape, position)
    next_state = nil
    if tape[position] == 1
      tape[position] = @write_if_one
      next_state = @next_state_if_one
      position += @move_if_one
    else
      tape[position] = @write_if_zero
      next_state = @next_state_if_zero
      position += @move_if_zero
    end
    [position, next_state]
  end
end

states = Hash.new
tape = Hash.new(0)
steps = 0
start_state = nil
current_state = nil
in_value_zero = true

file = File.open('../../input/2017/input_day25.txt', 'r')
while line = file.gets
  match = /Begin in state ([A-Z])\./.match(line)
  if match
    if states[match[1]].nil?
      states.merge!( match[1] => State.new(match[1]) )
    end
    start_state = states[match[1]]
  end

  match = /Perform a diagnostic checksum after (\d+) steps\./.match(line)
  if match
    steps = match[1].to_i
  end

  match = /In state ([A-Z]):/.match(line)
  if match
    if states[match[1]].nil?
      states.merge!( match[1] => State.new(match[1]) )
    end
    current_state = states[match[1]]
  end

  if line.strip == 'If the current value is 0:'
    in_value_zero = true
  end

  if line.strip == 'If the current value is 1:'
    in_value_zero = false
  end

  match = /- Write the value (\d)\./.match(line)
  if match
    if in_value_zero
      current_state.write_if_zero = match[1].to_i
    else
      current_state.write_if_one = match[1].to_i
    end
  end

  match = /- Move one slot to the (left|right)\./.match(line)
  if match
    if match[1] == 'left'
      if in_value_zero
        current_state.move_if_zero = -1
      else
        current_state.move_if_one = -1
      end
    else
      if in_value_zero
        current_state.move_if_zero = 1
      else
        current_state.move_if_one = 1
      end
    end
  end

  match = /- Continue with state ([A-Z])\./.match(line)
  if match
    if states[match[1]].nil?
      states.merge!( match[1] => State.new(match[1]) )
    end
    if in_value_zero
      current_state.next_state_if_zero = states[match[1]]
    else
      current_state.next_state_if_one = states[match[1]]
    end
  end
end
file.close

current_state = start_state
current_position = 0
1.upto(steps) do
  next_position, next_state = current_state.perform(tape, current_position)
  current_state = next_state
  current_position = next_position
end

puts tape.values.count(1)
