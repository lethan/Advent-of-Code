require 'pry-byebug'

file = File.open('input_day12.txt', 'r')
state = Hash.new(false)
transformations = {}
while (line = file.gets)
  if (match = /initial state: ([.#]+)/.match(line))
    match[1].split('').each_with_index do |value, index|
      state[index] = value == '#'
    end
  end
  if (match = /([.#]{5}) => ([.#])/.match(line))
    input = match[1].split('').map { |value| value == '#' }
    transformations[input] = match[2] == '#'
  end
end
file.close

def pot_sum(state, transformations, itterations)
  itteration = 1
  known_states = []
  known_states << [state.values, state.keys.first]
  while itteration <= itterations
    new_state = Hash.new(false)
    min, max = state.keys.minmax
    (min - 2).upto(max + 2) do |index|
      new_state[index] = transformations[[state[index - 2], state[index - 1], state[index], state[index + 1], state[index + 2]]]
    end
    new_state.delete(new_state.keys.min) until new_state[new_state.keys.min]
    new_state.delete(new_state.keys.max) until new_state[new_state.keys.max]
    state = new_state
    if (found_known = known_states.index { |a| a[0] == state.values })
      index_change = state.keys.first - known_states[found_known].last
      step_size = known_states.length - found_known
      steps = (itterations - itteration) / step_size
      total_index_change = steps * index_change
      itteration += steps * step_size
      new_state = Hash.new(false)
      state.each do |key, value|
        new_state[key + total_index_change] = value
      end
      state = new_state
      known_states = []
    end
    known_states << [state.values, state.keys.first]
    itteration += 1
  end
  state.select { |_, v| v }.keys.sum
end

puts pot_sum(state.dup, transformations, 20)
puts pot_sum(state.dup, transformations, 50_000_000_000)
