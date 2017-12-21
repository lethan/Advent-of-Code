file = File.open('input_day04.txt', 'r')
sector_sum = 0
storage = 0
while line = file.gets
  match = /(.*)-(\d+)\[([a-z]{5})\]/.match(line)
  string = match[1]
  string.gsub('-', '')
  sector_id = match[2].to_i
  checksum = string.chars.each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort_by{ |k,v| [-v,k] }[0..4].map {|a| a[0]}.join
  sector_sum += sector_id if checksum == match[3]
  string = match[1]
  shift = sector_id % 26
  room = string.chars.map{|a| a == '-' ? ' ' : ((a.ord - 'a'.ord + shift) % 26 + 'a'.ord).chr }.join
  storage = sector_id if room == "northpole object storage"
end
file.close
puts sector_sum
puts storage
