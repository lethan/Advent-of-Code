# frozen_string_literal: true

file = File.open('input_day06.txt', 'r')
input = {}
while (line = file.gets)
  orbit_objects = line.chomp.split(')')
  input[orbit_objects[0]] = { orbit_objects: [], orbits_around: nil } if input[orbit_objects[0]].nil?
  input[orbit_objects[1]] = { orbit_objects: [], orbits_around: nil } if input[orbit_objects[1]].nil?
  input[orbit_objects[0]][:orbit_objects] << orbit_objects[1]
  input[orbit_objects[1]][:orbits_around] = orbit_objects[0]
end

def total_orbits(orbits, object, current_orbits)
  total_orbits = current_orbits
  orbits[object][:orbit_objects].each do |obj|
    total_orbits += total_orbits(orbits, obj, current_orbits + 1)
  end
  total_orbits
end

def orbits_around(orbits, object, list)
  return list if orbits[object][:orbits_around].nil?

  orbits_around(orbits, orbits[object][:orbits_around], list << orbits[object][:orbits_around])
end

def orbit_changes(orbits, source, destination)
  source_orbits = orbits_around(orbits, source, [])
  destination_orbits = orbits_around(orbits, destination, [])
  (source_orbits - destination_orbits).size + (destination_orbits - source_orbits).size
end

puts total_orbits(input, 'COM', 0)
puts orbit_changes(input, 'YOU', 'SAN')
