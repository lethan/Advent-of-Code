# frozen_string_literal: true

# Room
class Room
  @@all_rooms = {}
  attr_reader :north_door, :south_door, :east_door, :west_door, :minimum_steps

  def self.all_rooms
    @@all_rooms
  end

  def self.print_map
    min_x, max_x = @@all_rooms.keys.map { |a| a[:x] }.minmax
    min_y, max_y = @@all_rooms.keys.map { |a| a[:y] }.minmax
    min_y.upto(max_y) do |y|
      y_positions = y == min_y ? %i[top middle bottom] : %i[middle bottom]
      y_positions.each do |y_position|
        row = []
        min_x.upto(max_x) do |x|
          x_positions = x == min_x ? %i[left middle right] : %i[middle right]
          x_positions.each do |x_position|
            char = ' '
            case y_position
            when :top
              case x_position
              when :left
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x - 1, y: y }] || @@all_rooms[{ x: x, y: y - 1 }] || @@all_rooms[{ x: x - 1, y: y - 1 }]
              when :middle
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x, y: y - 1 }]
                char = '-' if @@all_rooms[{ x: x, y: y }]&.door?(:north)
              when :right
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x + 1, y: y }] || @@all_rooms[{ x: x, y: y - 1 }] || @@all_rooms[{ x: x + 1, y: y - 1 }]
              end
            when :middle
              case x_position
              when :left
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x - 1, y: y }]
                char = '|' if @@all_rooms[{ x: x, y: y }]&.door?(:west)
              when :middle
                char = '.' if @@all_rooms[{ x: x, y: y }]
                char = 'X' if @@all_rooms[{ x: x, y: y }] && x.zero? && y.zero?
              when :right
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x + 1, y: y }]
                char = '|' if @@all_rooms[{ x: x, y: y }]&.door?(:east)
              end
            when :bottom
              case x_position
              when :left
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x - 1, y: y }] || @@all_rooms[{ x: x, y: y + 1 }] || @@all_rooms[{ x: x - 1, y: y + 1 }]
              when :middle
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x, y: y + 1 }]
                char = '-' if @@all_rooms[{ x: x, y: y }]&.door?(:south)
              when :right
                char = '#' if @@all_rooms[{ x: x, y: y }] || @@all_rooms[{ x: x + 1, y: y }] || @@all_rooms[{ x: x, y: y + 1 }] || @@all_rooms[{ x: x + 1, y: y + 1 }]
              end
            end
            row << char
          end
        end
        puts row.join
      end
    end
    puts ''
  end

  def self.most_steps_to_room
    @@all_rooms.map { |_, v| v.minimum_steps }.max
  end

  def self.rooms_with_steps_with_minimum(input)
    @@all_rooms.map { |_, v| v.minimum_steps }.select { |v| v >= input }.length
  end

  def initialize(x_coord = 0, y_coord = 0, minimum_steps = 0)
    @x = x_coord
    @y = y_coord
    @north_door = false
    @south_door = false
    @east_door = false
    @west_door = false
    @minimum_steps = minimum_steps
    @@all_rooms[{ x: @x, y: @y }] = self
  end

  def step(direction, step)
    if door?(direction)
      case direction
      when :north
        tmp = @@all_rooms[{ x: @x, y: @y - 1 }]
        tmp.update_steps(step)
        tmp
      when :south
        tmp = @@all_rooms[{ x: @x, y: @y + 1 }]
        tmp.update_steps(step)
        tmp
      when :east
        tmp = @@all_rooms[{ x: @x + 1, y: @y }]
        tmp.update_steps(step)
        tmp
      when :west
        tmp = @@all_rooms[{ x: @x - 1, y: @y }]
        tmp.update_steps(step)
        tmp
      end
    else
      case direction
      when :north
        @north_door = true
        tmp = Room.new(@x, @y - 1, step)
        @@all_rooms[{ x: @x, y: @y - 1 }] = tmp
        tmp
      when :south
        @south_door = true
        tmp = Room.new(@x, @y + 1, step)
        @@all_rooms[{ x: @x, y: @y + 1 }] = tmp
        tmp
      when :east
        @east_door = true
        tmp = Room.new(@x + 1, @y, step)
        @@all_rooms[{ x: @x + 1, y: @y }] = tmp
        tmp
      when :west
        @west_door = true
        tmp = Room.new(@x - 1, @y, step)
        @@all_rooms[{ x: @x - 1, y: @y }] = tmp
        tmp
      end
    end
  end

  def door?(direction)
    case direction
    when :north
      @north_door || @@all_rooms[{ x: @x, y: @y - 1 }]&.south_door
    when :south
      @south_door || @@all_rooms[{ x: @x, y: @y + 1 }]&.north_door
    when :east
      @east_door || @@all_rooms[{ x: @x + 1, y: @y }]&.west_door
    when :west
      @west_door || @@all_rooms[{ x: @x - 1, y: @y }]&.east_door
    end
  end

  def update_steps(step)
    @minimum_steps = step if step < @minimum_steps
  end
end

def regex_map(regex, current_room, step = 0)
  return if regex.empty?

  if regex[0] == '^'
    end_index = regex.index('$')
    raise 'Invalid input' if end_index != regex.length - 1

    regex_map(regex[1..end_index - 1], current_room, step)
  else
    start = 0
    parentheses_depth = 0
    splitted = false
    regex.split('').each_with_index do |value, index|
      parentheses_depth += 1 if value == '('
      parentheses_depth -= 1 if value == ')'
      if value == '|' && parentheses_depth.zero?
        regex_map(regex[start..index - 1], current_room, step)
        start = index + 1
        splitted = true
      end
      raise 'Invalid parentheses' if parentheses_depth.negative?
      raise 'Invalid input' if value == '^'
    end
    raise 'Invalid parentheses' unless parentheses_depth.zero?

    if splitted
      regex_map(regex[start..-1], current_room, step)
    else
      case regex[0]
      when 'N'
        new_room = current_room.step(:north, step + 1)
        regex_map(regex[1..-1], new_room, step + 1)
      when 'S'
        new_room = current_room.step(:south, step + 1)
        regex_map(regex[1..-1], new_room, step + 1)
      when 'E'
        new_room = current_room.step(:east, step + 1)
        regex_map(regex[1..-1], new_room, step + 1)
      when 'W'
        new_room = current_room.step(:west, step + 1)
        regex_map(regex[1..-1], new_room, step + 1)
      when '('
        parentheses_depth = 0
        regex.split('').each_with_index do |value, index|
          parentheses_depth += 1 if value == '('
          parentheses_depth -= 1 if value == ')'
          if parentheses_depth.zero?
            regex_map(regex[1..index - 1], current_room, step)
            regex_map(regex[index + 1..-1], current_room, step)
            break
          end
        end
      else
        raise 'Invalid input'
      end
    end
  end
end

file = File.open('../../input/2018/input_day20.txt', 'r')
regex = +''
while (line = file.gets)
  regex << line.chomp
end
file.close

start_room = Room.new
regex_map(regex, start_room)
puts Room.most_steps_to_room
puts Room.rooms_with_steps_with_minimum(1000)
