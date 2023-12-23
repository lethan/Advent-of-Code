# Beings
class Being
  attr_accessor :x, :y, :hit_points, :attack
  include Comparable

  def initialize(x_coord, y_coord, attack = 3)
    @x = x_coord
    @y = y_coord
    @hit_points = 200
    @attack = attack
  end

  def <=>(other)
    cmp = @y <=> other.y
    return cmp unless cmp.zero?

    @x <=> other.x
  end

  def healthcmp(other)
    cmp = @hit_points <=> other.hit_points
    return cmp unless cmp.zero?

    self <=> other
  end

  def hit(attack, maze, goblins, elfs)
    @hit_points -= attack
    unless @hit_points.positive?
      maze[@y][@x] = nil
      goblins.delete(self)
      elfs.delete(self)
    end
  end
end

# Elf
class Elf < Being
end

# Goblin
class Goblin < Being
end

# Wall
class Wall
end

def print_maze(maze)
  maze.each do |row|
    hit_points = []
    output = row.map do |field|
      case field
      when Goblin
        hit_points << "G(#{field.hit_points})"
        'G'
      when Elf
        hit_points << "E(#{field.hit_points})"
        'E'
      when Wall
        '#'
      else
        '.'
      end
    end
    puts output.join + '   ' + hit_points.join(', ')
  end
  nil
end

def next_to_opponents(x_coord, y_coord, maze, being)
  opponent_klass = being.class == Elf ? Goblin : Elf
  [{ x: x_coord, y: y_coord - 1 }, { x: x_coord - 1, y: y_coord }, { x: x_coord + 1, y: y_coord }, { x: x_coord, y: y_coord + 1 }].map do |coord|
    maze[coord[:y]][coord[:x]]&.is_a?(opponent_klass) ? maze[coord[:y]][coord[:x]] : nil
  end.compact
end

def next_to_vancant(being, maze)
  vacancies = false
  -1.upto(1) do |y|
    -1.upto(1) do |x|
      next if x.abs == y.abs

      vacancies ||= maze[being.y + y][being.x + x].nil?
    end
  end
  vacancies
end

file = File.open('../../input/2018/input_day15.txt', 'r')
maze = []
elfs = []
goblins = []
wall = Wall.new
row_number = 0
while (line = file.gets)
  row = []
  line.chomp.split('').each_with_index do |value, index|
    type = nil
    case value
    when '#'
      type = wall
    when 'E'
      elf = Elf.new(index, row_number)
      elfs << elf
    when 'G'
      goblin = Goblin.new(index, row_number)
      goblins << goblin
    else
      puts "UNKOWN INPUT: '#{value}'" if value != '.'
    end
    row << type
  end
  maze << row
  row_number += 1
end
file.close

def perform_battle(old_maze, old_elfs, old_goblins, elf_attack = 3)
  maze = []
  old_maze.each do |row|
    maze << row.dup
  end
  elfs = []
  old_elfs.each do |elf|
    new_elf = elf.dup
    new_elf.attack = elf_attack
    maze[new_elf.y][new_elf.x] = new_elf
    elfs << new_elf
  end
  goblins = []
  old_goblins.each do |goblin|
    new_goblin = goblin.dup
    maze[new_goblin.y][new_goblin.x] = new_goblin
    goblins << new_goblin
  end

  rounds = 0
  until elfs.empty? || goblins.empty?
    full_round = true
    beings = elfs + goblins
    beings.sort.each do |being|
      next unless being.hit_points.positive?

      full_round = false if elfs.empty? || goblins.empty?
      vacancies = false
      case being
      when Goblin
        elfs.each do |elf|
          vacancies ||= next_to_vancant(elf, maze)
        end
      when Elf
        goblins.each do |goblin|
          vacancies ||= next_to_vancant(goblin, maze)
        end
      end
      if vacancies
        visited = Array.new(maze.length) { Array.new(maze[0].length, nil) }
        queue = []
        steps = []
        coord = { x: being.x, y: being.y }
        queue << [coord, steps]
        while (current = queue.shift)
          coord = current.first
          steps = current.last
          next if visited[coord[:y]][coord[:x]]

          visited[coord[:y]][coord[:x]] = steps
          unless next_to_opponents(coord[:x], coord[:y], maze, being).empty?
            maze[being.y][being.x] = nil

            first_step = steps.first
            if first_step
              being.x += first_step[:x]
              being.y += first_step[:y]
            end
            maze[being.y][being.x] = being
            queue = []
          else
            -1.upto(1) do |y|
              -1.upto(1) do |x|
                next if x.abs == y.abs

                new_coord = { x: coord[:x] + x, y: coord[:y] + y }
                step = { x: x, y: y }
                queue << [new_coord, steps.dup << step] if maze[new_coord[:y]][new_coord[:x]].nil?
              end
            end
          end
        end
      end

      opponents = next_to_opponents(being.x, being.y, maze, being)
      unless opponents.empty?
        opponent = opponents.min(&:healthcmp)
        opponent.hit(being.attack, maze, goblins, elfs)
      end
    end
    rounds += 1 if full_round
  end
  beings = elfs + goblins
  [beings.map(&:hit_points).sum * rounds, elfs]
end

puts perform_battle(maze, elfs, goblins).first
elf_attack = 4
while (outcome = perform_battle(maze, elfs, goblins, elf_attack))
  break if outcome.last.length == elfs.length
  elf_attack += 1
end
puts outcome.first
