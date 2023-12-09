input = "cqjxjnds"

def next_password(input)
  values = input.chars.map {|a| a.ord - 97}.reverse

  looking = true
  while looking
    carry = 1
    values.each_with_index do |value, index|
      new_value = values[index] + carry
      values[index] = new_value % 26
      carry = new_value / 26
    end
    last1 = -1
    last2 = -1
    first_pair = -1
    increasing = false
    invalid = false
    pairs = false
    values.each do |value|
      invalid = true if value == 8
      invalid = true if value == 11
      invalid = true if value == 14
      break if invalid

      if last2 == last1 + 1 && last1 == value + 1
        increasing = true
      end
      if last1 == value
        if first_pair == -1
          first_pair = value
        else
          if value != first_pair
            pairs = true
          end
        end
      end
      last2 = last1
      last1 = value
    end
    looking = false if !invalid && increasing && pairs
  end

  values.reverse.map { |a| (a+97).chr }.join
end

new_password = next_password(input)
puts new_password
puts next_password(new_password)
