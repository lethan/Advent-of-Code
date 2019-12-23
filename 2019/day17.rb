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
  directions = []
  current_step = 0
  current_node = start_node
  last_node = nil
  while current_node
    edges = current_node.edges
    case edges.size
    when 1, 2
      edge = nil
      if edges.size == 1
        edge = edges.first
      else
        edges.each do |e|
          edge = e unless e.nodes.include?(last_node)
        end
      end
      other_node = nil
      edge.nodes.each do |node|
        other_node = node if current_node != node
      end
      case edge.direction
      when :horizontal
        case direction
        when :robot_up
          directions << current_step.to_s unless current_step.zero?
          current_step = 0
          if current_node.coordinate[0] < other_node.coordinate[0]
            directions << 'R'
            direction = :robot_right
          else
            directions << 'L'
            direction = :robot_left
          end
        when :robot_down
          directions << current_step.to_s unless current_step.zero?
          current_step = 0
          if current_node.coordinate[0] > other_node.coordinate[0]
            directions << 'R'
            direction = :robot_left
          else
            directions << 'L'
            direction = :robot_right
          end
        when :robot_left
          if current_node.coordinate[0] < other_node.coordinate[0]
            directions << current_step.to_s unless current_step.zero?
            current_node = nil
          else
            current_step += edge.steps
            last_node = current_node
            current_node = other_node
          end
        when :robot_right
          if current_node.coordinate[0] > other_node.coordinate[0]
            directions << current_step.to_s unless current_step.zero?
            current_node = nil
          else
            current_step += edge.steps
            last_node = current_node
            current_node = other_node
          end
        end
      when :vertical
        case direction
        when :robot_up
          if current_node.coordinate[1] < other_node.coordinate[1]
            directions << current_step.to_s unless current_step.zero?
            current_node = nil
          else
            current_step += edge.steps
            last_node = current_node
            current_node = other_node
          end
        when :robot_down
          if current_node.coordinate[1] > other_node.coordinate[1]
            directions << current_step.to_s unless current_step.zero?
            current_node = nil
          else
            current_step += edge.steps
            last_node = current_node
            current_node = other_node
          end
        when :robot_left
          directions << current_step.to_s unless current_step.zero?
          current_step = 0
          if current_node.coordinate[1] > other_node.coordinate[1]
            directions << 'R'
            direction = :robot_up
          else
            directions << 'L'
            direction = :robot_down
          end
        when :robot_right
          directions << current_step.to_s unless current_step.zero?
          current_step = 0
          if current_node.coordinate[1] < other_node.coordinate[1]
            directions << 'R'
            direction = :robot_down
          else
            directions << 'L'
            direction = :robot_up
          end
        end
      end
    when 4
      edge = nil
      edge_dir = case direction
                 when :robot_up, :robot_down
                   :vertical
                 when :robot_left, :robot_right
                   :horizontal
                 end
      edges.each do |e|
        edge = e if e.direction == edge_dir && !e.nodes.include?(last_node)
      end
      other_node = nil
      edge.nodes.each do |node|
        other_node = node if current_node != node
      end
      current_step += edge.steps
      last_node = current_node
      current_node = other_node
    end
  end
  directions
end

def byte_pair_encoding(sequence, translations = {})
  length_main = sequence.map { |s| s.is_a?(Symbol) ? 1 : s.length }.sum + sequence.size - 1
  if length_main <= 20 && sequence.uniq.count { |a| a.is_a? Symbol } <= 3
    main = sequence.clone
    programs = []
    (0..2).each do |program_number|
      main_symbol = main.find { |a| a.is_a? Symbol }
      main.map! { |a| a == main_symbol ? (program_number + 65).chr : a }
      programs[program_number] = []
      if main_symbol
        translations[main_symbol].each do |t|
          programs[program_number] << t
        end
      end
      while (symbol = programs[program_number].find { |a| a.is_a? Symbol })
        new_program = []
        programs[program_number].each do |s|
          if s == symbol
            translations[symbol].each do |t|
              new_program << t
            end
          else
            new_program << s
          end
        end
        programs[program_number] = new_program
      end
      return { status: :invalid } if programs[program_number].map(&:length).sum + programs[program_number].size - 1 > 20
    end
    return { status: :ok, main: main, program_a: programs[0], program_b: programs[1], program_c: programs[2] }
  end

  frequency = {}
  (0..sequence.size - 2).each do |index|
    frequency[[sequence[index], sequence[index + 1]]] = { count: 0, indices: [] } if frequency[[sequence[index], sequence[index + 1]]].nil?
    frequency[[sequence[index], sequence[index + 1]]][:count] += 1
    frequency[[sequence[index], sequence[index + 1]]][:indices] << index
  end
  return { status: :invalid } if frequency.empty?

  frequency.sort_by { |v| -v[1][:count] }.each do |key, value|
    new_translations = translations.clone
    new_sequence = sequence.clone
    current_symbol = :var000000
    current_symbol = current_symbol.succ while new_translations[current_symbol]
    new_translations[current_symbol] = key
    indices = value[:indices].clone
    until indices.empty?
      index = indices.shift
      new_sequence[index, 2] = current_symbol
      indices.map! { |v| v == index + 1 ? nil : v - 1 }.compact!
    end
    result = byte_pair_encoding(new_sequence, new_translations)
    return result if result[:status] == :ok
  end
  { status: :invalid }
end

def programs(instruction_sequence)
  instruction_sequence.each_with_index do |value, index|
  end
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
edges(awake_nodes)
seq = vacuum_instruction_sequence(awake_nodes, awake_map)
program_data = byte_pair_encoding(seq)

main = program_data[:main].join(',') + "\n"
function_a = program_data[:program_a].join(',') + "\n"
function_b = program_data[:program_b].join(',') + "\n"
function_c = program_data[:program_c].join(',') + "\n"
option = "n\n"
inputs = main + function_a + function_b + function_c + option
ascii_awake.input_string(inputs)
last_out = 0
last_out = ascii_awake.output while ascii_awake.outputs?
puts last_out
