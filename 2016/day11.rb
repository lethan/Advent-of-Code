# The first floor contains a promethium generator and a promethium-compatible microchip.
# The second floor contains a cobalt generator, a curium generator, a ruthenium generator, and a plutonium generator.
# The third floor contains a cobalt-compatible microchip, a curium-compatible microchip, a ruthenium-compatible microchip, and a plutonium-compatible microchip.
# The fourth floor contains nothing relevant.

def itemsOnFloor(input, floor)
  input.select { |key, value| value == floor}.keys - [:elevator]
end

def validState(input)
  1.upto(4) do |floor|
    items = itemsOnFloor(input, floor).map(&:to_s)
    radioactive = items.map { |item| item[-2..-1] }.include?('_g')
    if radioactive
      items.each do |item|
        if item[-2..-1] == '_m'
          return false unless items.include?(item[0..-2] + 'g')
        end
      end
    end
  end
  true
end

def newState(current, floorChange, items)
  new_state = current.dup
  new_state[:elevator] += floorChange
  items.each do |item|
    new_state[item] += floorChange
  end
  new_state
end

def stepsToTop(current)
  all_steps = {}
  stack = [{ current: current, step_number: 0 }]
  while args = stack.shift
    current = args[:current]
    step_number = args[:step_number]

    next unless validState(current)
    next unless all_steps[current].nil? || all_steps[current] > step_number

    if current.values.all?(4)
      return step_number
    end

    all_steps[current] = step_number

    onFloor = itemsOnFloor(current, current[:elevator])

    if current[:elevator] < 4
      onFloor.each_with_index do |value, index|
        (index+1).upto(onFloor.length - 1) do |y|
          stack.push({ current: newState(current, 1, [value, onFloor[y]]), step_number: step_number + 1})
        end
        stack.push({ current: newState(current, 1, [value]), step_number: step_number + 1})
      end
    end
    if current[:elevator] > 1
      onFloor.each { |value| stack.push({ current: newState(current, -1, [value]), step_number: step_number + 1}) }
      onFloor.each_with_index do |value, index|
        (index+1).upto(onFloor.length - 1) do |y|
          stack.push({ current: newState(current, -1, [value, onFloor[y]]), step_number: step_number + 1})
        end
      end
    end
  end
end

input = { elevator: 1,
          cobalt_g: 2,
          cobalt_m: 3,
          curium_g: 2,
          curium_m: 3,
          plutonium_g: 2,
          plutonium_m: 3,
          promethium_g: 1,
          promethium_m: 1,
          ruthenium_g: 2,
          ruthenium_m: 3 }

puts stepsToTop(input)

input[:elerium_g] = 1
input[:elerium_m] = 1
input[:dilithium_g] = 1
input[:dilithium_m] = 1

puts stepsToTop(input)
