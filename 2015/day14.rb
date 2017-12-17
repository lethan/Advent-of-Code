finish_line = 2503
file = File.open('input_day14.txt', 'r')
reindeers = Hash.new
while line = file.gets
  match = /([a-zA-Z]+) can fly (\d+) km\/s for (\d+) seconds, but then must rest for (\d+) seconds./.match(line)
  reindeers.merge!( match[1] =>
    { speed: match[2].to_i,
      speed_period: match[3].to_i,
      rest_period: match[4].to_i,
      distance_per_period: match[2].to_i * match[3].to_i,
      period_length: match[3].to_i + match[4].to_i,
      points: 0
    })
end
file.close

leaders = []
max_distance = 0
1.upto(finish_line) do |number|
  leaders = []
  max_distance = 0
  reindeers.keys.each do |reindeer|
    periods = number / reindeers[reindeer][:period_length]
    distance = periods * reindeers[reindeer][:distance_per_period]
    extra_seconds = number % reindeers[reindeer][:period_length]
    if extra_seconds < reindeers[reindeer][:speed_period]
      distance += extra_seconds * reindeers[reindeer][:speed]
    else
      distance += reindeers[reindeer][:distance_per_period]
    end

    if distance == max_distance
      leaders += [reindeer]
    end
    if distance > max_distance
      max_distance = distance
      leaders = [reindeer]
    end
  end
  leaders.each do |leader|
    reindeers[leader][:points] += 1
  end
end

puts "#{leaders[0]} was fastest and flew #{max_distance} km"

max_points = 0
leader = []
reindeers.keys.each do |reindeer|
  if reindeers[reindeer][:points] > max_points
    max_points = reindeers[reindeer][:points]
    leader = [reindeer]
  end
end

puts "#{leader[0]} won most points with #{max_points} points"
