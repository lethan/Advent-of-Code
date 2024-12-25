# frozen_string_literal: true

require_relative 'intcode'

def print_section(section)
  x_minmax = section.keys.map { |a| a[:x] }.minmax
  y_minmax = section.keys.map { |a| a[:y] }.minmax
  (y_minmax[0]..y_minmax[1]).each do |y|
    (x_minmax[0]..x_minmax[1]).each do |x|
      if section[{ x: x, y: y }].nil?
        print ' '
      elsif
        if x.zero? && y.zero?
          print 'D'
        else
          case section[{ x: x, y: y }][:type]
          when :wall
            print '#'
          when :empty
            print '.'
          when :oxygen
            print 'O'
          end
        end
      end
    end
    print "\n"
  end
end

file = File.open('../../input/2019/input_day15.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

droid = Program.new(program)
section = {}
steps = []
step_count = 0
x_pos = 0
y_pos = 0
section[{ x: x_pos, y: y_pos }] = { type: :empty, steps: step_count }
seached_section = false
oxygen_steps = 0

until seached_section
  direction = nil
  if section[{ x: x_pos, y: y_pos - 1 }].nil? || (section[{ x: x_pos, y: y_pos - 1 }][:type] == :empty && section[{ x: x_pos, y: y_pos - 1 }][:steps] > step_count + 1)
    direction = 1
  elsif section[{ x: x_pos + 1, y: y_pos }].nil? || (section[{ x: x_pos + 1, y: y_pos }][:type] == :empty && section[{ x: x_pos + 1, y: y_pos }][:steps] > step_count + 1)
    direction = 4
  elsif section[{ x: x_pos, y: y_pos + 1 }].nil? || (section[{ x: x_pos, y: y_pos + 1 }][:type] == :empty && section[{ x: x_pos, y: y_pos + 1 }][:steps] > step_count + 1)
    direction = 2
  elsif section[{ x: x_pos - 1, y: y_pos }].nil? || (section[{ x: x_pos - 1, y: y_pos }][:type] == :empty && section[{ x: x_pos - 1, y: y_pos }][:steps] > step_count + 1)
    direction = 3
  else
    case steps.pop
    when 1
      direction = 2
    when 2
      direction = 1
    when 3
      direction = 4
    when 4
      direction = 3
    when nil
      direction = 1
      seached_section = true
    end
  end
  droid.input(direction)
  status = droid.output
  case status
  when 0
    case direction
    when 1
      section[{ x: x_pos, y: y_pos - 1 }] = { type: :wall }
    when 2
      section[{ x: x_pos, y: y_pos + 1 }] = { type: :wall }
    when 3
      section[{ x: x_pos - 1, y: y_pos }] = { type: :wall }
    when 4
      section[{ x: x_pos + 1, y: y_pos }] = { type: :wall }
    end
  when 1, 2
    case direction
    when 1
      y_pos -= 1
    when 2
      y_pos += 1
    when 3
      x_pos -= 1
    when 4
      x_pos += 1
    end
    if section[{ x: x_pos, y: y_pos }].nil? || section[{ x: x_pos, y: y_pos }][:steps] > step_count + 1
      step_count += 1
      steps << direction
      section[{ x: x_pos, y: y_pos }] = { type: :empty, steps: step_count, filling_time: nil }
      if status == 2
        section[{ x: x_pos, y: y_pos }] = { type: :oxygen, steps: step_count, filling_time: 0 }
        oxygen_steps = step_count
      end
    else
      step_count = section[{ x: x_pos, y: y_pos }][:steps]
    end
  end
end
puts oxygen_steps

fill_step = 0
while section.values.map { |h| h[:type] }.include?(:empty)
  section.select { |_, value| value[:type] == :oxygen && value[:filling_time] == fill_step }.keys.each do |key|
    (-1..1).each do |x|
      (-1..1).each do |y|
        next if x.abs == y.abs

        if section[{ x: key[:x] + x, y: key[:y] + y }][:type] == :empty
          section[{ x: key[:x] + x, y: key[:y] + y }][:type] = :oxygen
          section[{ x: key[:x] + x, y: key[:y] + y }][:filling_time] = fill_step + 1
        end
      end
    end
  end
  fill_step += 1
end
puts fill_step
