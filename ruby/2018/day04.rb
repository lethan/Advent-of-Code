file = File.open('../../input/2018/input_day04.txt', 'r')
timestamps = []
while line = file.gets
  timestamps << line.strip
end
file.close
timestamps.sort!

guards = {}
current_guard = nil
sleep_start = nil
timestamps.each do |stamp|
  if match = /\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}\] Guard #(\d+) begins shift/.match(stamp)
    current_guard = match[1].to_i
    if guards[current_guard].nil?
      guards[current_guard] = Array.new(60, 0)
    end
  end
  if match = /\[\d{4}-\d{2}-\d{2} \d{2}:(\d{2})\] falls asleep/.match(stamp)
    sleep_start = match[1].to_i
  end
  if match = /\[\d{4}-\d{2}-\d{2} \d{2}:(\d{2})\] wakes up/.match(stamp)
    sleep_start.upto(match[1].to_i - 1) do |minute|
      guards[current_guard][minute] += 1
    end
  end
end

most_sleeping_guard = guards.map{ |k, arr| [k, arr.sum] }.to_h.max_by{|k,v| v}[0]
puts most_sleeping_guard * guards[most_sleeping_guard].each_with_index.max[1]

most_sleeping_guard = guards.map{ |k, arr| [k, arr.each_with_index.max]}.max_by{|k, v| v[0]}
puts most_sleeping_guard[0] * most_sleeping_guard[1][1]
