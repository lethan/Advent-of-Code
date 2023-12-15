Node = Struct.new(:x, :y, :size, :used, :avail, :goal_data)

nodes = []
file = File.open('../../input/2016/input_day22.txt', 'r')
while (line = file.gets)
  if (match = /\/dev\/grid\/node-x(\d+)-y(\d+)\s+(\d+)T\s+(\d+)T\s+(\d+)T\s+\d+%/.match(line))
    goal_data = false
    goal_data = true if match[1].to_i == 36 && match[2].to_i.zero?
    nodes << Node.new(match[1].to_i, match[2].to_i, match[3].to_i, match[4].to_i, match[5].to_i, goal_data)
  end
end
file.close

viable_pairs = 0
pairs = {}
sorted_by_avail = nodes.sort_by(&:avail).reverse
nodes.sort_by(&:used).each do |node1|
  next if node1.used.zero?

  sorted_by_avail.each do |node2|
    next if node1 == node2
    break if node1.used > node2.avail

    viable_pairs += 1
    pairs[node2] = [] if pairs[node2].nil?
    pairs[node2] << node1
  end
end
puts viable_pairs

max_x = 0
max_y = 0

pairs.each do |k, v|
  max_x = [max_x, k.x, v.map(&:x).max].max
  max_y = [max_y, k.y, v.map(&:y).max].max
end

movable = Array.new(max_x + 1) { Array.new(max_y + 1, false) }
pairs.each do |key, values|
  movable[key.x][key.y] = true

  values.each do |value|
    movable[value.x][value.y] = true
  end
end

empty = { x: pairs.keys.first.x, y: pairs.keys.first.y }
goal = { x: max_x, y: 0 }
queue = []
visited = {}
steps = 0
queue << [empty, goal, steps]
while (current = queue.shift)
  empty = current.first
  goal = current[1]
  steps = current.last
  visit = { empty_x: empty[:x], empty_y: empty[:y], goal_x: goal[:x], goal_y: goal[:y] }
  break if goal[:x].zero? && goal[:y].zero?
  next unless visited[visit].nil?

  visited[visit] = steps

  -1.upto(1) do |x|
    -1.upto(1) do |y|
      next if x.abs == y.abs
      next if (empty[:x] + x).negative?
      next if (empty[:y] + y).negative?

      new_empty = { x: empty[:x] + x, y: empty[:y] + y }
      if movable.dig(new_empty[:x], new_empty[:y])
        queue << [new_empty, (new_empty == goal ? empty : goal), steps + 1]
      end
    end
  end
end
puts steps
