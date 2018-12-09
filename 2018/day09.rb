# 476 players; last marble is worth 71431 points

players = 476
marbles = 71_431

# CircleMarble
class CircleMarble
  attr_accessor :value, :clockwise, :counter_clockwise

  def initialize(value, clockwise = self, counter_clockwise = self)
    @value = value
    @clockwise = clockwise
    @counter_clockwise = counter_clockwise
  end

  def insert_new_marble(value)
    counter = @clockwise
    clockwise = counter.clockwise
    new_marble = CircleMarble.new(value, clockwise, counter)
    counter.clockwise = new_marble
    clockwise.counter_clockwise = new_marble
    new_marble
  end

  def steps_away(steps)
    return self if steps.zero?
    return @clockwise.steps_away(steps - 1) if steps > 0

    @counter_clockwise.steps_away(steps + 1)
  end
end

def max_score(players, marbles)
  current_circle_marble = CircleMarble.new(0)
  current_player = 0
  scores = Array.new(players, 0)
  1.upto(marbles) do |marble|
    if (marble %  23).zero?
      scores[current_player] += marble
      current_circle_marble = current_circle_marble.steps_away(-7)
      scores[current_player] += current_circle_marble.value
      current_circle_marble.counter_clockwise.clockwise = current_circle_marble.clockwise
      current_circle_marble.clockwise.counter_clockwise = current_circle_marble.counter_clockwise
      current_circle_marble = current_circle_marble.clockwise
    else
      current_circle_marble = current_circle_marble.insert_new_marble(marble)
    end
    current_player = (current_player + 1) % players
  end
  scores.max
end

puts max_score(players, marbles)
puts max_score(players, marbles * 100)
