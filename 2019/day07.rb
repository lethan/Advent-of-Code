# frozen_string_literal: true

# Programm class that runs programs
class Program
  def initialize(program)
    @program = program.clone
    @pointer = 0
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

  def run
    while @status == :running
      mode_one = @program[@pointer] / 100 % 10
      mode_two = @program[@pointer] / 1000 % 10
      mode_three = @program[@pointer] / 10_000 % 10

      case @program[@pointer] % 100
      when 1
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @program[@program[@pointer + 3]] = parameter_one + parameter_two
        @pointer += 4
      when 2
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @program[@program[@pointer + 3]] = parameter_one * parameter_two
        @pointer += 4
      when 3
        if @inputs.empty?
          @status = :waiting_for_input
        else
          @program[@program[@pointer + 1]] = @inputs.shift
          @pointer += 2
        end
      when 4
        @outputs << @program[@program[@pointer + 1]]
        @pointer += 2
      when 5
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @pointer += 3
        @pointer = parameter_two unless parameter_one.zero?
      when 6
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @pointer += 3
        @pointer = parameter_two if parameter_one.zero?
      when 7
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @program[@program[@pointer + 3]] = parameter_one < parameter_two ? 1 : 0
        @pointer += 4
      when 8
        parameter_one = mode_one.zero? ? @program[@program[@pointer + 1]] : @program[@pointer + 1]
        parameter_two = mode_two.zero? ? @program[@program[@pointer + 2]] : @program[@pointer + 2]
        @program[@program[@pointer + 3]] = parameter_one == parameter_two ? 1 : 0
        @pointer += 4
      when 99
        @status = :halted
      else
        puts "Unknown operation: #{@pointer} = #{@program[@pointer]}"
        @status = :unkown_operator
      end
    end
  end
end

file = File.open('input_day07.txt', 'r')
while (line = file.gets)
  program = line.strip.split(',').map(&:to_i)
end
file.close

max_output = 0
(0..4).each do |amp_a|
  result_a = Program.new(program).input(amp_a).input(0).output
  (0..4).each do |amp_b|
    next if [amp_a].include?(amp_b)

    result_b = Program.new(program).input(amp_b).input(result_a).output
    (0..4).each do |amp_c|
      next if [amp_a, amp_b].include?(amp_c)

      result_c = Program.new(program).input(amp_c).input(result_b).output
      (0..4).each do |amp_d|
        next if [amp_a, amp_b, amp_c].include?(amp_d)

        result_d = Program.new(program).input(amp_d).input(result_c).output
        (0..4).each do |amp_e|
          next if [amp_a, amp_b, amp_c, amp_d].include?(amp_e)

          result_e = Program.new(program).input(amp_e).input(result_d).output
          max_output = result_e if result_e > max_output
        end
      end
    end
  end
end
puts max_output

max_output = 0
(5..9).each do |amp_a|
  (5..9).each do |amp_b|
    next if [amp_a].include?(amp_b)

    (5..9).each do |amp_c|
      next if [amp_a, amp_b].include?(amp_c)

      (5..9).each do |amp_d|
        next if [amp_a, amp_b, amp_c].include?(amp_d)

        (5..9).each do |amp_e|
          next if [amp_a, amp_b, amp_c, amp_d].include?(amp_e)

          program_a = Program.new(program).input(amp_a)
          program_b = Program.new(program).input(amp_b)
          program_c = Program.new(program).input(amp_c)
          program_d = Program.new(program).input(amp_d)
          program_e = Program.new(program).input(amp_e)

          last_input = 0
          program_e_out = nil
          ended = false

          until ended
            program_a.input(last_input)
            ended ||= program_a.ended?

            program_b.input(program_a.output)
            ended ||= program_b.ended?

            program_c.input(program_b.output)
            ended ||= program_c.ended?

            program_d.input(program_c.output)
            ended ||= program_d.ended?

            program_e.input(program_d.output)
            ended ||= program_e.ended?

            last_input = program_e.output
            program_e_out = last_input unless last_input.nil?
          end
          max_output = program_e_out if program_e_out && program_e_out > max_output
        end
      end
    end
  end
end
puts max_output
