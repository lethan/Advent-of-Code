# frozen_string_literal: true

require_relative 'intcode'

class Node
  def initialize(x, y, directions)
    @x = x
    @y = y
    @directions = directions
    @edges = []
  end

  def coordinate
    [@x, @y]
  end

  def directions
    @directions.clone
  end

  def remove_direction(direction)
    @directions.delete(direction)
  end

  def add_edge(edge)
    @edges << edge
  end

  def edges
    @edges
  end
end

class Edge
  def initialize(node_a, node_b, direction, steps)
    @node_a = node_a
    @node_b = node_b
    @direction = direction
    @steps = steps
  end

  def nodes
    [@node_a, @node_b]
  end

  def direction
    @direction
  end

  def steps
    @steps
  end
end

def vacuum_map(ascii)
  vacuum_map = []
  current_line = []
  while ascii.outputs?
    code = ascii.output
    case code
    when 46
      current_line << :empty
    when 35
      current_line << :scaffold
    when 10
      vacuum_map << current_line unless current_line.empty?
      current_line = []
    when 94
      current_line << :robot_up
    when 118
      current_line << :robot_down
    when 60
      current_line << :robot_left
    when 62
      current_line << :robot_right
    end
  end
  vacuum_map
end

def nodes(vacuum_map, only_intersections = false)
  nodes = {}
  (0..vacuum_map.size - 1).each do |y|
    (0..vacuum_map[y].size - 1).each do |x|
      next if vacuum_map[y][x] == :empty

      directions = []
      (-1..1).each do |vertical|
        next if (y + vertical).negative? || y + vertical >= vacuum_map.size

        (-1..1).each do |horizontal|
          next if (x + horizontal).negative? || x + horizontal >= vacuum_map[y].size
          next if vertical.abs == horizontal.abs

          directions << [horizontal, vertical] if vacuum_map[y + vertical][x + horizontal] != :empty
        end
      end

      nodes[{ x: x, y: y }] = Node.new(x, y, directions) if directions.size == 4

      next if only_intersections

      nodes[{ x: x, y: y }] = Node.new(x, y, directions) if directions.size % 2 == 1
      nodes[{ x: x, y: y }] = Node.new(x, y, directions) if directions.size == 2 && directions.first[0].abs != directions.last[0].abs
    end
  end
  nodes
end

def edges(nodes)
  edges = []
  nodes.each do |key, node_a|
    node_a.directions.each do |direction|
      steps = 1
      until (node_b = nodes[{ x: key[:x] + direction[0] * steps, y: key[:y] + direction[1] * steps }])
        steps += 1
      end
      dir = case direction.map(&:abs)
            when [1, 0]
              :horizontal
            when [0, 1]
              :vertical
            end
      edge = Edge.new(node_a, node_b, dir, steps)
      edges << edge
      node_a.remove_direction(direction)
      node_b.remove_direction(direction.map(&:-@))
      node_a.add_edge(edge)
      node_b.add_edge(edge)
    end
  end
  edges
end

def vacuum_instruction_sequence(nodes, vacuum_map)
  start_node = nil
  direction = nil
  %i[robot_up robot_down robot_right robot_left].each do |robot_direction|
    next unless (y = vacuum_map.index { |a| a.include?(robot_direction) })

    x = vacuum_map[y].index(robot_direction)
    start_node = nodes[{ x: x, y: y }]
    direction = robot_direction
  end
  [start_node, direction]
end

program = []
file = File.open('input_day17.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

ascii = Program.new(program)
vacuum_map = vacuum_map(ascii)

alignment_sum = 0
nodes(vacuum_map, true).each do |_, node|
  alignment_sum += node.coordinate.reduce(:*)
end
puts alignment_sum

new_program = program.clone
new_program[0] = 2
ascii_awake = Program.new(new_program)
awake_map = vacuum_map(ascii_awake)
awake_nodes = nodes(awake_map)
awake_edges = edges(awake_nodes)
vacuum_instruction_sequence(awake_nodes, awake_map)

sequence = "L,12,L,12,R,4,R,10,R,6,R,4,R,4,L,12,L,12,R,4,R,6,L,12,L,12,R,10,R,6,R,4,R,4,L,12,L,12,R,4,R,10,R,6,R,4,R,4,R,6,L,12,L,12,R,6,L,12,L,12,R,10,R,6,R,4,R,4"
main = "A,B,A,C,B,A,B,C,C,B\n"
function_a = "L,12,L,12,R,4\n"
function_b = "R,10,R,6,R,4,R,4\n"
function_c = "R,6,L,12,L,12\n"
option = "n\n"
inputs = main + function_a + function_b + function_c + option
inputs.split('').each do |char|
  ascii_awake.input(char.ord)
end
last_out = 0
last_out = ascii_awake.output while ascii_awake.outputs?
puts last_out
