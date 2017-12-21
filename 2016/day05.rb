require 'digest/md5'

input = "reyedfim"
index = -1
password = []
password2 = Array.new(8,nil)
chars_to_go = 8
still_looking = true

while still_looking
  index += 1
  hash = Digest::MD5.hexdigest(input + index.to_s)
  if hash[0..4] == "0" * 5
    if chars_to_go > 0
      password << hash[5]
      chars_to_go -= 1
    end
    if (0..7).to_a.map(&:to_s).include?(hash[5])
      if password2[hash[5].to_i].nil?
        password2[hash[5].to_i] = hash[6]
      end
    end
    if chars_to_go == 0 && !password2.include?(nil)
      still_looking = false
    end
  end
end

puts password.join
puts password2.join
