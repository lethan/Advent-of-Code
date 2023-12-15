class Bot
  attr_accessor :number
  attr_accessor :output_low
  attr_accessor :output_high
  attr_accessor :inputs

  def initialize(number)
    @inputs = []
    @number = number
  end

  def value(from)
    value1 = @inputs[0]
    if value1.is_a? Bot
      value1 = value1.value(self)
    end
    value2 = @inputs[1]
    if value2.is_a? Bot
      value2 = value2.value(self)
    end
    @inputs = [value1, value2].sort

    @output_low == from ? @inputs[0] : @inputs[1]
  end
end

class Output
  attr_accessor :number
  attr_accessor :output
  attr_accessor :input

  def initialize(number)
    @number = number
  end

  def value
    @output ||= input.value(self)
  end
end

bots = Hash.new
outputs = Hash.new

file = File.open('../../input/2016/input_day10.txt', 'r')
while line = file.gets
  match = /(bot (\d+) gives low to (bot|output) (\d+) and high to (bot|output) (\d+))|(value (\d+) goes to bot (\d+))/.match(line)
  if match[1]
    number = match[2].to_i
    bot = bots[number] ||= Bot.new(number)
    output_low = nil
    number_low = match[4].to_i
    if match[3] == "bot"
      output_low = bots[number_low] ||= Bot.new(number_low)
      output_low.inputs << bot
    else
      output_low = outputs[number_low] ||= Output.new(number_low)
      output_low.input = bot
    end
    bot.output_low = output_low
    output_high = nil
    number_high = match[6].to_i
    if match[5] == "bot"
      output_high = bots[number_high] ||= Bot.new(number_high)
      output_high.inputs << bot
    else
      output_high = outputs[number_high] ||= Output.new(number_high)
      output_high.input = bot
    end
    bot.output_high = output_high
  end
  if match[7]
    number = match[9].to_i
    value = match[8].to_i
    bot = bots[number] ||= Bot.new(number)
    bot.inputs << value
  end
end
file.close

outputs.each { |k,v| v.value }
bots.each do |k, bot|
  if bot.inputs == [17,61]
    puts bot.number
  end
end

puts outputs[0].output * outputs[1].output * outputs[2].output
