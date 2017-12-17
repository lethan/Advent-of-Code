class Point
  attr_reader :value
  attr_accessor :next_point

  def initialize(value)
    @value = value
  end
end

current_point = Point.new(0)
current_point.next_point = current_point
null_point = current_point

input = 314

1.upto(50_000_000) do |number|
  1.upto(input) do
    current_point = current_point.next_point
  end
  new_point = Point.new(number)
  new_point.next_point = current_point.next_point
  current_point.next_point = new_point
  current_point = new_point
  if number == 2017
    puts current_point.next_point.value
  end
end

puts null_point.next_point.value
