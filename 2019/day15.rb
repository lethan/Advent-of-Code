# frozen_string_literal: true

class Program
  def initialize(program)
    @program = program.clone
    @pointer = 0
    @relative_base = 0
    @inputs = []
    @outputs = []
    @status = :running
    run
  end

  def input(input)
    @inputs << input unless input.nil?
    @status = :running
    run
    self
  end

  def output
    @outputs.shift
  end

  def outputs?
    !@outputs.empty?
  end

  def ended?
    @status == :halted
  end

  def get_program_address(address)
    valid_program(address)
    @program[address]
  end

  def set_program_address(address, value)
    valid_program(address)
    @program[address] = value
  end

  private

  def valid_program(address)
    return unless @program.size <= address

    @program.size.upto(address) do |index|
      @program[index] = 0
    end
  end

  def run
    while @status == :running
      instruction = get_program_address(@pointer)
      mode_one = instruction / 100 % 10
      mode_two = instruction / 1_000 % 10
      mode_three = instruction / 10_000 % 10

      parameter_one = case mode_one
                      when 0
                        get_program_address(@pointer + 1)
                      when 1
                        @pointer + 1
                      when 2
                        get_program_address(@pointer + 1) + @relative_base
                      else
                        @status = :unkown_parameter_mode_one
                        0
                      end
      parameter_two = case mode_two
                      when 0
                        get_program_address(@pointer + 2)
                      when 1
                        @pointer + 2
                      when 2
                        get_program_address(@pointer + 2) + @relative_base
                      else
                        @status = :unkown_parameter_mode_one
                        0
                      end
      parameter_three = case mode_three
                        when 0
                          get_program_address(@pointer + 3)
                        when 1
                          @pointer + 3
                        when 2
                          get_program_address(@pointer + 3) + @relative_base
                        else
                          @status = :unkown_parameter_mode_one
                          0
                        end

      case instruction % 100
      when 1
        set_program_address(parameter_three, get_program_address(parameter_one) + get_program_address(parameter_two))
        @pointer += 4
      when 2
        set_program_address(parameter_three, get_program_address(parameter_one) * get_program_address(parameter_two))
        @pointer += 4
      when 3
        if @inputs.empty?
          @status = :waiting_for_input
        else
          set_program_address(parameter_one, @inputs.shift)
          @pointer += 2
        end
      when 4
        @outputs << get_program_address(parameter_one)
        @pointer += 2
      when 5
        @pointer += 3
        @pointer = get_program_address(parameter_two) unless get_program_address(parameter_one).zero?
      when 6
        @pointer += 3
        @pointer = get_program_address(parameter_two) if get_program_address(parameter_one).zero?
      when 7
        set_program_address(parameter_three, get_program_address(parameter_one) < get_program_address(parameter_two) ? 1 : 0)
        @pointer += 4
      when 8
        set_program_address(parameter_three, get_program_address(parameter_one) == get_program_address(parameter_two) ? 1 : 0)
        @pointer += 4
      when 9
        @relative_base += get_program_address(parameter_one)
        @pointer += 2
      when 99
        @status = :halted
      else
        puts "Unknown instruction: #{@pointer} = #{@program[@pointer]}"
        @status = :unkown_instruction
      end
    end
  end
end

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

file = File.open('input_day15.txt', 'r')
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
