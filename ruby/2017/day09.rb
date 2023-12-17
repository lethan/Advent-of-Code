class Group
  attr_accessor :content
  attr_accessor :level

  def initialize(level)
    @level = level
    @content = []
  end
end

class Garbage
  attr_accessor :content

  def initialize(content)
    @content = content
  end
end

file = File.open("../../input/2017/input_day09.txt", "r")
while line = file.gets
  temp = line
end
file.close

top = Group.new(0)
def parse(input, current_group)
  if input.chars.first == "{"
    in_garbage = false
    level = 0
    skip_char = 0
    input.chars.each_with_index do |char, index|
      if !in_garbage
        if char == "{"
          level += 1
        end
        if char == "}"
          level -= 1
        end
        if char == "<"
          in_garbage = true
          skip_char = 0
        end
      elsif in_garbage
        if char == ">" && skip_char == 0
          in_garbage = false
        end
        if char == "!" && skip_char == 0
          skip_char = 2
        end
        if skip_char > 0
          skip_char -= 1
        end
      end
      if level == 0
        next_level = current_group.level + 1
        current_group.content << parse(input[1..index-1], Group.new(next_level))
        parse(input[index+1..-1], current_group)
        break
      end
    end
  end
  if input.chars.first == ","
    parse(input[1..-1], current_group)
  end
  if input.chars.first == "<"
    skip_char = 1
    data = ""
    input.chars.each_with_index do |char, index|
      if char == ">" && skip_char == 0
        current_group.content << Garbage.new(data)
        parse(input[index+1..-1], current_group)
        break
      end
      if char == "!" && skip_char == 0
        skip_char = 2
      end
      if skip_char == 0
        data += char
      end
      if skip_char > 0
        skip_char -= 1
      end
    end
  end
  current_group
end

def score(input)
  score = 0
  if input.is_a? Group
    score += input.level
    input.content.each do |item|
      score += score(item)
    end
  end
  score
end

def characters(input)
  characters = 0
  if input.is_a? Group
    input.content.each do |item|
      characters += characters(item)
    end
  end
  if input.is_a? Garbage
    characters += input.content.length
  end
  characters
end

parse(temp, top)
puts score(top)
puts characters(top)
