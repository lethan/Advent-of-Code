file = File.open('../../input/2018/input_day06.txt', 'r')
places = []
while (line = file.gets)
  places << line.strip.split(', ').map(&:to_i)
end
file.close

smallest_x, largest_x = places.map(&:first).minmax
smallest_y, largest_y = places.map(&:last).minmax
smallest_x -= 1
smallest_y -= 1
largest_x += 1
largest_y += 1

closest = {}
places.each_with_index do |place, index|
  smallest_x.upto(largest_x) do |x|
    smallest_y.upto(largest_y) do |y|
      coord = { x: x, y: y }
      distance = (place.first - x).abs + (place.last - y).abs
      closest[coord] = { distance: distance, closest: [], all_distances: [] } if closest[coord].nil?
      closest[coord][:all_distances] << distance
      closest[coord][:closest] << index if closest[coord][:distance] == distance
      if distance < closest[coord][:distance]
        closest[coord][:distance] = distance
        closest[coord][:closest] = [index]
      end
    end
  end
end

infinite_places = []
places.each_with_index do |place, index|
  infinite_places << index if closest[{ x: smallest_x,  y: place.last }][:closest] == [index] ||
                              closest[{ x: largest_x,   y: place.last }][:closest] == [index] ||
                              closest[{ x: place.first, y: smallest_y }][:closest] == [index] ||
                              closest[{ x: place.first, y: largest_y  }][:closest] == [index]
end

puts closest.select { |_, close| close[:closest].length == 1 && !infinite_places.include?(close[:closest].first) }
            .map { |_, p| p[:closest] }.flatten.each_with_object(Hash.new(0)) { |e, total| total[e] += 1 }.max_by { |_, v| v }[1]

less_than = 10_000
puts closest.select { |_, close| close[:all_distances].sum < less_than }.count
