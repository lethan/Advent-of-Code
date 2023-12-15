require 'digest/md5'

input = 'ihaygndm'

def valid_hash_count(hashes)
  count = 0
  hashes.keys.sort.each do |key|
    return count unless hashes[key][:valid]

    count += 1
  end
  count
end

def hash_index(input, stretching = 0)
  found_hashes = {}
  current_number = 0
  while valid_hash_count(found_hashes) < 64
    hash = input + current_number.to_s
    0.upto(stretching) { hash = Digest::MD5.hexdigest(hash) }
    0.upto(29) do |i|
      if hash[i..(i + 2)] == hash[i] * 3
        found_hashes[current_number] = { letter: hash[i], valid: false }
        break
      end
    end
    0.upto(27) do |i|
      if hash[i..(i + 4)] == hash[i] * 5
        ((current_number - 1000)..(current_number - 1)).each do |v|
          unless found_hashes[v].nil?
            if found_hashes[v][:letter] == hash[i]
              found_hashes[v][:valid] = true
            end
          end
        end
      end
    end
    unless found_hashes[current_number - 1000].nil?
      found_hashes.delete(current_number - 1000) unless found_hashes[current_number - 1000][:valid]
    end
    current_number += 1
  end

  found_hashes.keys.sort[63]
end

puts hash_index(input)
puts hash_index(input, 2016)
