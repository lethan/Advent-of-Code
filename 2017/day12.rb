file = File.open("input_day12.txt", "r")
programs = {}
while line = file.gets
  arr = line.split(' <-> ')
  connecions = arr[1].split(', ').map(&:to_i)
  programs[arr[0].to_i] = [connecions, false]
end
file.close

def connected(program, programs, connections)
  if connections[program].nil?
    connections[program] = true
    programs[program][1] = true
    programs[program][0].each do |connection|
      connections.merge(connected(connection, programs, connections))
    end
  end
  connections
end

groups = []
connections = connected(0, programs, {})
groups << connecions
puts connections.count

programs.each do |program, info|
  if !info[1]
    groups << connected(program, programs, {})
  end
end

puts groups.length
