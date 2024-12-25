# frozen_string_literal: true

# Programm class that runs programs
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

  def ended?
    @status == :halted
  end

  private

  def valid_program(address)
    return unless @program.size <= address

    @program.size.upto(address) do |index|
      @program[index] = 0
    end
  end

  def get_program_address(address)
    valid_program(address)
    @program[address]
  end

  def set_program_address(address, value)
    valid_program(address)
    @program[address] = value
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

file = File.open('../../input/2019/input_day11.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

def painter(program, panels)
  direction = :up
  x_coord = 0
  y_coord = 0
  painter = Program.new(program)

  until painter.ended?
    painter.input(panels[[x_coord, y_coord]])
    panels[[x_coord, y_coord]] = painter.output
    turn = painter.output
    case direction
    when :up
      direction = if turn.zero?
                    :left
                  else
                    :right
                  end
    when :down
      direction = if turn.zero?
                    :right
                  else
                    :left
                  end
    when :right
      direction = if turn.zero?
                    :up
                  else
                    :down
                  end
    when :left
      direction = if turn.zero?
                    :down
                  else
                    :up
                  end
    end
    case direction
    when :up
      y_coord += 1
    when :down
      y_coord -= 1
    when :right
      x_coord += 1
    when :left
      x_coord -= 1
    end
  end
  panels
end

panels = Hash.new(0)
puts painter(program, panels).size

panels = Hash.new(0)
panels[[0, 0]] = 1
painter(program, panels)
x_minmax = panels.keys.map(&:first).minmax
y_minmax = panels.keys.map(&:last).minmax
y_minmax[1].downto(y_minmax[0]) do |y|
  (x_minmax[0]..x_minmax[1]).each do |x|
    print panels[[x, y]].zero? ? ' ' : '#'
  end
  print "\n"
end
