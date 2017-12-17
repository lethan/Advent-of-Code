require 'digest/md5'

input = "bgvyzdsv"
def first(input, count)
  still_looking = true
  current_number = -1
  while still_looking
    current_number += 1
    hash = Digest::MD5.hexdigest(input + current_number.to_s)
    if hash[0..count-1] == "0" * count
      still_looking = false
    end
  end
  current_number
end

puts first(input, 5)
puts first(input, 6)
