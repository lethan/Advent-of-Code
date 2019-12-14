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

def display_game(tiles, interactive = false)
  system 'clear' if interactive
  rows = tiles.keys.map(&:last).max
  columns = tiles.keys.map(&:first).max
  (0..rows).each do |row|
    (0..columns).each do |column|
      print case tiles[[column, row]]
            when 0
              ' '
            when 1
              '#'
            when 2
              'X'
            when 3
              '-'
            when 4
              'o'
            else
              ' '
            end
    end
    print "\n"
    $stdout.flush
  end
  puts ''
  $stdout.flush
  sleep(0.15) if interactive
end

file = File.open('input_day13.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end

tiles_program = Program.new(program)
tiles = {}
while (x_pos = tiles_program.output)
  y_pos = tiles_program.output
  tile_id = tiles_program.output
  tiles[[x_pos, y_pos]] = tile_id
end

blocks = 0
tiles.each do |_, tile|
  blocks += 1 if tile == 2
end
puts blocks

game_program = program.clone
game_program[0] = 2
game = Program.new(game_program)
tiles = {}
x_pos, y_pos = 0
ball_pos = 0
paddle_pos = 0
next_out = :x_pos
until game.ended? && !game.outputs?
  while (output = game.output)
    case next_out
    when :x_pos
      x_pos = output
      next_out = :y_pos
    when :y_pos
      y_pos = output
      next_out = :tile_id
    when :tile_id
      tile_id = output
      tiles[[x_pos, y_pos]] = tile_id
      next_out = :x_pos
      paddle_pos = x_pos if tile_id == 3
      ball_pos = x_pos if tile_id == 4
    end
  end
  #display_game(tiles)
  game.input(ball_pos <=> paddle_pos)
end
puts tiles[[-1, 0]]
