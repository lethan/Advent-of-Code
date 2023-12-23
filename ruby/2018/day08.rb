file = File.open('../../input/2018/input_day08.txt', 'r')
input = []
while (line = file.gets)
  input += line.split(' ').map(&:to_i)
end

# Node class
class Node
  attr_accessor :children_count, :children, :meta_data_count, :meta_data

  def initialize(input)
    @children_count = input.shift
    @meta_data_count = input.shift
    @children = []
    @meta_data = []
    fill_data(input)
  end

  def fill_data(input)
    1.upto(@children_count) do
      child = Node.new(input)
      @children << child
    end
    1.upto(@meta_data_count) do
      @meta_data << input.shift
    end
  end

  def total_meta_data
    @meta_data.sum + @children.map(&:total_meta_data).sum
  end

  def value
    @value ||= if @children_count.zero?
                 @meta_data.sum
               else
                 @meta_data.map { |meta| @children[meta - 1].nil? ? 0 : @children[meta - 1].value }.sum
               end
  end
end

top_node = Node.new(input)
puts top_node.total_meta_data
puts top_node.value
