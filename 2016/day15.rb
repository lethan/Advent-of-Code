def create_enumerator(disk_number, disk_positions, start_position)
  Enumerator.new do |yielder|
    position = (start_position + disk_number) % disk_positions
    position = (disk_positions - position) % disk_positions
    loop do
      yielder << position
      position += disk_positions
    end
  end
end

def minimum_wait(disks)
  minimum_wait = -1
  found_valid = false

  until found_valid
    found_valid = true
    disks.each do |disk|
      current = disk[0]
      current = disk[1].next while current < minimum_wait
      disk[0] = current
      if current > minimum_wait
        minimum_wait = current
        found_valid = false
      end
    end
  end
  minimum_wait
end

file = File.open('input_day15.txt', 'r')
disks = []
while (line = file.gets)
  match = /Disc #(\d+) has (\d+) positions; at time=0, it is at position (\d+)./.match(line.strip)
  enumerator = create_enumerator(match[1].to_i.dup, match[2].to_i.dup, match[3].to_i.dup)
  disks << [enumerator.next, enumerator]
end
file.close

puts minimum_wait(disks)
enumerator = create_enumerator(7, 11, 0)
disks << [enumerator.next, enumerator]
puts minimum_wait(disks)
