# frozen_string_literal: true

bugs = []
file = File.open('input_day24.txt', 'r')
row = 0
bug_levels = {}
bug_levels[0] = {}
while (line = file.gets)
  line.strip.split('').each_with_index do |a, column|
    value = a == '#' ? 1 : 0
    bugs.prepend(value)
    bug_levels[0][{ x: column, y: row }] = value unless column == 2 && row == 2
  end
  row += 1
end
file.close

def print_bugs(bugs)
  counter = 0
  bugs.reverse_each do |bug|
    print bug.zero? ? '.' : '#'
    counter += 1
    print "\n" if (counter % 5).zero?
  end
  puts
end

def print_bug_level(bug_levels)
  bug_levels.keys.sort.each do |level|
    puts "Depth #{level}:"
    (0..4).each do |y|
      (0..4).each do |x|
        if x == 2 && y == 2
          print '?'
        else
          print bug_levels[level][{ x: x, y: y }] == 1 ? '#' : '.'
        end
      end
      puts
    end
    puts
  end
end

seen = {}
counter = 0
until seen[bugs]
  seen[bugs] = counter
  counter += 1
  new_bugs = []
  bugs.each_with_index do |value, index|
    adjunct = 0
    [-5, -1, 1, 5].each do |diff|
      next if (index + diff).negative?
      next if (index % 5).zero? && diff == -1
      next if (index % 5) == 4 && diff == 1

      adjunct += 1 if bugs[index + diff] == 1
    end
    new_bugs << case value
                when 0
                  [1, 2].include?(adjunct) ? 1 : 0
                when 1
                  adjunct == 1 ? 1 : 0
                end
  end
  bugs = new_bugs
end
puts bugs.join.to_i(2)

adjunct = {}
(1..200).each do
  adjunct = {}
  bug_levels.each do |level, current_bugs|
    current_bugs.select { |_, value| value == 1 }.each do |coordinate, _|
      (-1..1).each do |y|
        (-1..1).each do |x|
          next if y.abs == x.abs

          new_x = coordinate[:x] + x
          new_y = coordinate[:y] + y
          level_change_x = new_x / 5
          level_change_y = new_y / 5
          if !level_change_x.zero?
            new_level = level - 1
            adjunct[new_level] = {} if adjunct[new_level].nil?
            adjunct[new_level][{ x: 2 + level_change_x, y: 2 }] = 0 if adjunct[new_level][{ x: 2 + level_change_x, y: 2 }].nil?
            adjunct[new_level][{ x: 2 + level_change_x, y: 2 }] += 1
          elsif !level_change_y.zero?
            new_level = level - 1
            adjunct[new_level] = {} if adjunct[new_level].nil?
            adjunct[new_level][{ x: 2, y: 2 + level_change_y }] = 0 if adjunct[new_level][{ x: 2, y: 2 + level_change_y }].nil?
            adjunct[new_level][{ x: 2, y: 2 + level_change_y }] += 1
          elsif new_x == 2 && new_y == 2
            new_level = level + 1
            (0..4).each do |x_or_y|
              tmp_x = coordinate[:y] == 2 ? (coordinate[:x] / 2) * 4 : x_or_y
              tmp_y = coordinate[:x] == 2 ? (coordinate[:y] / 2) * 4 : x_or_y
              adjunct[new_level] = {} if adjunct[new_level].nil?
              adjunct[new_level][{ x: tmp_x, y: tmp_y }] = 0 if adjunct[new_level][{ x: tmp_x, y: tmp_y }].nil?
              adjunct[new_level][{ x: tmp_x, y: tmp_y }] += 1
            end
          else
            adjunct[level] = {} if adjunct[level].nil?
            adjunct[level][{ x: new_x, y: new_y }] = 0 if adjunct[level][{ x: new_x, y: new_y }].nil?
            adjunct[level][{ x: new_x, y: new_y }] += 1
          end
        end
      end
    end
  end
  new_bug_levels = {}
  (adjunct.keys + bug_levels.keys).uniq.sort.each do |level|
    coordinates = bug_levels[level]&.select { |_, v| v > 0 }&.keys || []
    coordinates += adjunct[level]&.select { |_, v| v > 0 }&.keys || []
    coordinates.uniq.each do |coordinate|
      new_bug_levels[level] = {} if new_bug_levels[level].nil?
      case bug_levels.dig(level, coordinate)
      when 0, nil
        new_bug_levels[level][coordinate] = 1 if [1, 2].include?(adjunct.dig(level, coordinate))
      when 1
        new_bug_levels[level][coordinate] = 1 if adjunct.dig(level, coordinate) == 1
      end
    end
  end
  bug_levels = new_bug_levels
end
puts bug_levels.map { |_, v1| v1.count { |_, v2| v2.positive? } }.sum
