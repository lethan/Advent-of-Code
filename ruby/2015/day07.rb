class Value
  def initialize(value, schema)
    @value = value
    @schema = schema
  end

  def value
    @value
  end
end

class Variable
  def initialize(variable, schema)
    @variable = variable
    @schema = schema
  end

  def value
    if @schema[@variable].nil?
      puts "#{@variable} er nil"
    end
    @value ||= @schema[@variable].value
  end
end

class And
  def initialize(value1, variable2, schema)
    @value1 = value1
    @variable2 = variable2
    @schema = schema
  end

  def value
    @value ||= (@value1.to_i > 0 ? @value1.to_i : @schema[@value1].value) & @schema[@variable2].value & 0xFFFF
  end
end

class Or
  def initialize(value1, variable2, schema)
    @value1 = value1
    @variable2 = variable2
    @schema = schema
  end

  def value
    @value ||= (@value1.to_i > 0 ? @value1.to_i : @schema[@value1].value) | @schema[@variable2].value & 0xFFFF
  end
end

class Rshift
  def initialize(variable, positions, schema)
    @variable = variable
    @positions = positions
    @schema = schema
  end

  def value
    @value ||= @schema[@variable].value >> @positions & 0xFFFF
  end
end

class Lshift
  def initialize(variable, positions, schema)
    @variable = variable
    @positions = positions
    @schema = schema
  end

  def value
    @value ||= @schema[@variable].value << @positions & 0xFFFF
  end
end

class Not
  def initialize(variable, schema)
    @variable = variable
    @schema = schema
  end

  def value
    @value ||= ~@schema[@variable].value & 0xFFFF
  end
end

input = []
file = File.open('../../input/2015/input_day07.txt', 'r')
while line = file.gets
  input << line
end
file.close

def setup_schema(input)
  values = {}
  input.each do |str|
    match = /^(([a-z0-9]+)|([a-z0-9]+) (AND|OR) ([a-z]+)|(([a-z]+) ((?:L|R)SHIFT) (\d+))|(NOT) ([a-z]+)) -> (\S+)/.match(str)
    inserted = false
    output = match[12]
    if match[2]
      if match[2].scan(/^\d+$/).any?
        values[output] = Value.new(match[2].to_i, values)
      else
        values[output] = Variable.new(match[2], values)
      end
      inserted = true
    end
    if match[4]
      if match[4] == "AND"
        values[output] = And.new(match[3], match[5], values)
      end
      if match[4] == "OR"
        values[output] = Or.new(match[3], match[5], values)
      end
      inserted = true
    end
    if match[8]
      if match[8] == "LSHIFT"
        values[output] = Lshift.new(match[7], match[9].to_i, values)
      end
      if match[8] == "RSHIFT"
        values[output] = Rshift.new(match[7], match[9].to_i, values)
      end
      inserted = true
    end
    if match[10]
      values[output] = Not.new(match[11], values)
      inserted = true
    end
  end
  values
end

part1_schema = setup_schema(input)
a = part1_schema['a'].value
puts a

part2_schema = setup_schema(input)
part2_schema['b'] = Value.new(a, part2_schema)
puts part2_schema['a'].value
