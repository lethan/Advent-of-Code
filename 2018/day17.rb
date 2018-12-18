# frozen_string_literal: true

# Block
class Block
  attr_accessor :min_x, :max_x, :min_y, :max_y

  def initialize(min_x, max_x, min_y, max_y)
    @min_x = min_x
    @max_x = max_x
    @min_y = min_y
    @max_y = max_y
  end

  def self.x_with_range(x_val, y_range)
    new(x_val, x_val, y_range.min, y_range.max)
  end

  def self.y_with_range(y_val, x_range)
    new(x_range.min, x_range.max, y_val, y_val)
  end

  def create_underground(underground, base_info)
    @min_x.upto(@max_x) do |x|
      @min_y.upto(@max_y) do |y|
        underground[y - base_info[:min_y]][x - base_info[:min_x]] = Clay.new
      end
    end
  end
end

# Clay
class Clay
end

# Source
class Source
  attr_accessor :x, :y

  def initialize(x_coord, y_coord)
    @x = x_coord
    @y = y_coord
  end
end

# Water
class Water
  attr_accessor :x, :y, :source, :type

  def initialize(x_coord, y_coord, source)
    @x = x_coord
    @y = y_coord
    @source = source
    @type = :downflow
  end
end

def print_underground(underground)
  underground.each do |row|
    output = row.map do |field|
      case field
      when Clay
        '#'
      when Source
        '+'
      when Water
        field.type == :downflow ? '|' : '~'
      else
        '.'
      end
    end
    puts output.join
  end
  nil
end

def mark_still(x_coord, y_coord, underground, direction)
  block = underground[y_coord][x_coord + direction]
  return unless block&.is_a?(Water)

  block.type = :still
  mark_still(x_coord + direction, y_coord, underground, direction)
end

def flow_horizontal(source, underground, base_info, direction = 0)
  if direction.zero?
    left  = flow_horizontal(source, underground, base_info, -1)
    right = flow_horizontal(source, underground, base_info,  1)
    if left && right
      mark_still(source.x - base_info[:min_x], source.y - base_info[:min_y], underground, -1)
      source.type = :still
      mark_still(source.x - base_info[:min_x], source.y - base_info[:min_y], underground, 1)
    end
    return left && right
  end

  full_row = true
  underneath = underground[source.y - base_info[:min_y] + 1][source.x - base_info[:min_x]]
  full_row = false if underneath&.is_a?(Water) && underneath.type == :downflow

  if underneath.nil?
    water = Water.new(source.x, source.y + 1, source)
    underground[water.y - base_info[:min_y]][water.x - base_info[:min_x]] = water
    full_row &&= water_flow(water, underground, base_info)
  end
  block = underground[source.y - base_info[:min_y]][source.x - base_info[:min_x] + direction]
  if full_row && block.nil?
    water = Water.new(source.x + direction, source.y, source)
    underground[water.y - base_info[:min_y]][water.x - base_info[:min_x]] = water
    result = flow_horizontal(water, underground, base_info, direction)
    full_row &&= result
  end
  full_row
end

def water_flow(source, underground, base_info)
  blocked = false
  return blocked if source.y >= base_info[:max_y]

  underneath = underground[source.y - base_info[:min_y] + 1][source.x - base_info[:min_x]]
  return blocked if underneath&.is_a?(Water) && underneath.type == :downflow

  blocked = underneath&.is_a?(Clay) || (underneath&.is_a?(Water) && underneath.type == :still)

  water = Water.new(source.x, source.y + 1, source)
  if underneath.nil?
    underground[water.y - base_info[:min_y]][water.x - base_info[:min_x]] = water
    blocked = water_flow(water, underground, base_info)
  end
  blocked ||= (underneath.is_a?(Water) && underneath.type == :still)
  if blocked
    blocked = flow_horizontal(source, underground, base_info) if blocked
  end
  blocked
end

file = File.open('input_day17.txt', 'r')
blocks = []
while (line = file.gets)
  match = /(x|y)=(\d+), (x|y)=(\d+)..(\d+)/.match(line.chomp)
  if match
    blocks << Block.x_with_range(match[2].to_i, match[4].to_i..match[5].to_i) if match[1] == 'x'
    blocks << Block.y_with_range(match[2].to_i, match[4].to_i..match[5].to_i) if match[1] == 'y'
  end
end
file.close

base_info = {}
base_info[:min_x]        = blocks.map(&:min_x).min - 1
base_info[:max_x]        = blocks.map(&:max_x).max + 1
base_info[:result_min_y] = blocks.map(&:min_y).min
base_info[:min_y]        = [base_info[:result_min_y], 0].min
base_info[:max_y]        = blocks.map(&:max_y).max

underground = Array.new(base_info[:max_y] - base_info[:min_y] + 1) { Array.new(base_info[:max_x] - base_info[:min_x] + 1, nil) }

blocks.each { |b| b.create_underground(underground, base_info) }

source = Source.new(500, 0)
underground[source.y - base_info[:min_y]][source.x - base_info[:min_x]] = source

water_flow(source, underground, base_info)

puts underground[(base_info[:result_min_y] - base_info[:min_y])..(base_info[:max_y] - base_info[:min_y])].flatten.select { |s| s&.is_a?(Water) }.length
puts underground[(base_info[:result_min_y] - base_info[:min_y])..(base_info[:max_y] - base_info[:min_y])].flatten.select { |s| s&.is_a?(Water) && s.type == :still }.length
