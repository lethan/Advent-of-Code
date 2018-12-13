# Cart
class Cart
  include Comparable
  attr_accessor :x, :y, :direction, :steps, :current_track, :deleted

  def initialize(x_coord, y_coord, direction, current_track = nil)
    @x = x_coord
    @y = y_coord
    @direction = direction
    @current_track = current_track
    @steps = 0
    @next_intersection = :left
    @deleted = false
  end

  def move(tracks)
    return if @deleted

    @current_track.current_cart = nil
    @steps += 1
    case @direction
    when :right
      @x += 1
    when :left
      @x -= 1
      if @x.negative?
        @deleted = true
        return [[@x, @y], self]
      end
    when :up
      @y -= 1
      if @y.negative?
        @deleted = true
        return [[@x, @y], self]
      end
    when :down
      @y += 1
    end
    new_track = tracks.dig(@y, @x)
    if new_track.nil?
      @deleted = true
      return [[@x, @y], self]
    end

    if new_track.current_cart
      other = new_track.current_cart
      new_track.current_cart = nil
      other.deleted = true
      @deleted = true
      return [[@x, @y], self, other]
    end

    new_track.current_cart = self
    @current_track = new_track
    case new_track.type
    when :intersection
      intersection
    when :up_right
      up_right
    when :right_down
      right_down
    end
    nil
  end

  def <=>(other)
    cmp = @y <=> other.y
    return cmp unless cmp.zero?

    @x <=> other.x
  end

  private

  def intersection
    case @next_intersection
    when :left
      @direction = left(@direction)
      @next_intersection = :straight
    when :straight
      @next_intersection = :right
    when :right
      @direction = right(@direction)
      @next_intersection = :left
    end
  end

  def up_right
    @direction = case @direction
                 when :right
                   :up
                 when :left
                   :down
                 when :down
                   :left
                 when :up
                   :right
                 end
  end

  def right_down
    @direction = case @direction
                 when :right
                   :down
                 when :left
                   :up
                 when :down
                   :right
                 when :up
                   :left
                 end
  end

  def right(direction)
    case direction
    when :up
      :right
    when :right
      :down
    when :down
      :left
    when :left
      :up
    end
  end

  def left(direction)
    case direction
    when :up
      :left
    when :right
      :up
    when :down
      :right
    when :left
      :down
    end
  end
end

# Track
class Track
  attr_accessor :x, :y, :type, :current_cart

  def initialize(x_coord, y_coord, type, current_cart = nil)
    @x = x_coord
    @y = y_coord
    @type = type
    @current_cart = current_cart
  end
end

def print_tracks(tracks)
  tracks.each do |row|
    output = row.map do |track|
      next ' ' if track.nil?

      if track.current_cart.nil?
        case track.type
        when :left_right
          '-'
        when :up_down
          '|'
        when :intersection
          '+'
        when :right_down
          '\\'
        when :up_right
          '/'
        else
          '*'
        end
      else
        case track.current_cart.direction
        when :up
          '^'
        when :down
          'v'
        when :right
          '>'
        when :left
          '<'
        end
      end
    end
    puts output.join
  end
  nil
end

def directions_except(direction)
  %i[left_right up_down up_right right_down intersection] - [direction]
end

carts = []
tracks = []
file = File.open('input_day13.txt', 'r')
row = 0
while (line = file.gets)
  x_row = []
  line.chomp.split('').each_with_index do |value, index|
    type = nil
    case value
    when '<'
      carts << Cart.new(index, row, :left)
    when '>'
      carts << Cart.new(index, row, :right)
    when 'v'
      carts << Cart.new(index, row, :down)
    when '^'
      carts << Cart.new(index, row, :up)
    when '|'
      type = Track.new(index, row, :up_down)
    when '-'
      type = Track.new(index, row, :left_right)
    when '/'
      type = Track.new(index, row, :up_right)
    when '\\'
      type = Track.new(index, row, :right_down)
    when '+'
      type = Track.new(index, row, :intersection)
    else
      puts "UNKOWN INPUT: '#{value}'" if value != ' '
    end
    x_row << type
  end
  tracks << x_row
  row += 1
end
file.close

until carts.select { |a| a.current_track.nil? }.empty?
  carts.each do |cart|
    type = nil
    up_track = cart.y.zero? ? nil : tracks.dig(cart.y - 1, cart.x)
    down_track = tracks.dig(cart.y + 1, cart.x)
    left_track = cart.x.zero? ? nil : tracks.dig(cart.y, cart.x - 1)
    right_track = tracks.dig(cart.y, cart.x + 1)
    case cart.direction
    when :up
      type = :up_down if directions_except(:left_right).include?(down_track&.type)
      type = :intersection if type == :up_down && directions_except(:up_down).include?(left_track&.type) &&
                              directions_except(:up_down).include?(right_track&.type)
      type = :up_right if type.nil? && directions_except(:up_down).include?(left_track&.type)
      type = :right_down if type.nil? && directions_except(:up_down).include?(right_track&.type)
    when :down
      type = :up_down if directions_except(:left_right).include?(up_track&.type)
      type = :intersection if type == :up_down && directions_except(:up_down).include?(left_track&.type) &&
                              directions_except(:up_down).include?(right_track&.type)
      type = :up_right if type.nil? && directions_except(:up_down).include?(right_track&.type)
      type = :right_down if type.nil? && directions_except(:up_down).include?(left_track&.type)
    when :left
      type = :left_right if directions_except(:up_down).include?(right_track&.type)
      type = :intersection if type == :left_right && directions_except(:left_right).include?(up_track&.type) &&
                              directions_except(:left_right).include?(down_track&.type)
      type = :up_right if type.nil? && directions_except(:left_right).include?(up_track&.type)
      type = :right_down if type.nil? && directions_except(:left_right).include?(down_track&.type)
    when :right
      type = :left_right if directions_except(:up_down).include?(left_track&.type)
      type = :intersection if type == :left_right && directions_except(:left_right).include?(up_track&.type) &&
                              directions_except(:left_right).include?(down_track&.type)
      type = :up_right if type.nil? && directions_except(:left_right).include?(down_track&.type)
      type = :right_down if type.nil? && directions_except(:left_right).include?(up_track&.type)
    end
    next unless type

    track = Track.new(cart.x, cart.y, type, cart)
    tracks[cart.y][cart.x] = track
    cart.current_track = track
  end
end

collisions = []
while carts.length > 1
  removeable_carts = []
  carts.sort.each do |cart|
    collision = cart.move(tracks)
    collisions << collision.shift if collision
    removeable_carts += collision if collision
  end
  removeable_carts.each do |cart|
    carts.delete(cart)
  end
end
puts collisions.first.map(&:to_s).join(',')
puts "#{carts.first.x},#{carts.first.y}"
