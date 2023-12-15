file = File.open('../../input/2016/input_day18.txt', 'r')
while (line = file.gets)
  last_row = line.chomp.split('').map { |c| c == '.' }
end
file.close

row_count = 1
safe_tiles = last_row.select { |b| b }.length
while row_count < 400_000
  puts safe_tiles if row_count == 40
  last_row = [true] + last_row + [true]
  new_row = []
  0.upto(last_row.length - 3) do |i|
    new_row << ![[false, false, true], [true, false, false], [false, true, true], [true, true, false]].include?(last_row[i..(i + 2)])
  end
  last_row = new_row
  safe_tiles += last_row.select { |b| b }.length
  row_count += 1
end
puts safe_tiles
