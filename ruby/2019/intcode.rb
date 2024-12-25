# frozen_string_literal: true

class Program
  def initialize(program)
    @original_program = program.clone
    restart
  end

  def restart
    @program = @original_program.clone
    @pointer = 0
    @relative_base = 0
    @inputs = []
    @outputs = []
    @status = :running
    run
    self
  end

  def input(input)
    @inputs << input unless input.nil?
    @status = :running
    run
    self
  end

  def input_string(input_string)
    input_string.split('').each do |char|
      input(char.ord)
    end
  end

  def output
    @outputs.shift
  end

  def output_ascii
    output.chr
  end

  def output_string
    out = ''.dup
    out << output_ascii while outputs?
    out.freeze
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
