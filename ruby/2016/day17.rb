require 'digest/md5'

input = 'vwbaicqe'

queuee = []
position = { x: 0, y: 0 }
route = ''
queuee << [route, position]
shortest_route = nil
longest_route = 0
while (s = queuee.shift)
  route = s.first
  position = s.last
  if position == { x: 3, y: 3 }
    shortest_route ||= route
    longest_route = route.length if route.length > longest_route
    next
  end

  next if position[:x] < 0
  next if position[:x] > 3
  next if position[:y] < 0
  next if position[:y] > 3

  hash = Digest::MD5.hexdigest(input + route)
  if %w[b c d e f].include?(hash[0])
    new_position = { x: position[:x], y: position[:y] - 1 }
    queuee << [route + 'U', new_position]
  end
  if %w[b c d e f].include?(hash[1])
    new_position = { x: position[:x], y: position[:y] + 1 }
    queuee << [route + 'D', new_position]
  end
  if %w[b c d e f].include?(hash[2])
    new_position = { x: position[:x] - 1, y: position[:y] }
    queuee << [route + 'L', new_position]
  end
  if %w[b c d e f].include?(hash[3])
    new_position = { x: position[:x] + 1, y: position[:y] }
    queuee << [route + 'R', new_position]
  end
end
puts shortest_route
puts longest_route
