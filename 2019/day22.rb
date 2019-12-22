# frozen_string_literal: true

shuffle_instructions = []
file = File.open('input_day22.txt', 'r')
while (line = file.gets)
  shuffle_instructions << case line.strip
                          when 'deal into new stack'
                            [:reverse]
                          when /cut (-?\d+)/
                            [:cut, Regexp.last_match(1).to_i]
                          when /deal with increment (\d+)/
                            [:deal, Regexp.last_match(1).to_i]
                          end
end
file.close

def nth_card(nth, offset, increment, deck_size)
  (offset + increment * nth) % deck_size
end

def inverse(nth, deck_size)
  nth.pow(deck_size - 2, deck_size)
end

def calc_offset_and_increment(shuffle_instructions, deck_size)
  offset = 0
  increment = 1
  shuffle_instructions.each do |instruction|
    inst, arg = instruction
    case inst
    when :reverse
      increment *= -1
      increment %= deck_size
      offset += increment
      offset %= deck_size
    when :cut
      offset += increment * arg
      offset %= deck_size
    when :deal
      increment *= arg.pow(deck_size - 2, deck_size)
      increment %= deck_size
    end
  end
  [offset, increment]
end

def shuffle(deck_size, shuffle_instructions)
  offset, increment = calc_offset_and_increment(shuffle_instructions, deck_size)
  cards = []
  (0..deck_size - 1).each do |n|
    cards << nth_card(n, offset, increment, deck_size)
  end
  cards
end

def iterations(iterations, offset, increment, deck_size)
  new_increment = increment.pow(iterations, deck_size)
  offset = offset * (1 - new_increment) * inverse((1 - increment) % deck_size, deck_size)
  offset %= deck_size
  [offset, new_increment]
end

def card_at_index(card_index, shuffle_instructions, deck_size, number_of_shuffles)
  offset, increment = calc_offset_and_increment(shuffle_instructions, deck_size)
  offset, increment = iterations(number_of_shuffles, offset, increment, deck_size)
  nth_card(card_index, offset, increment, deck_size)
end

puts shuffle(10_007, shuffle_instructions).index(2019)
puts card_at_index(2020, shuffle_instructions, 119_315_717_514_047, 101_741_582_076_661)
