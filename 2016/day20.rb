# IpRange
class IpRange
  include Comparable

  attr_accessor :lower, :upper

  def initialize(lower, upper)
    @lower = lower
    @upper = upper
  end

  def <=>(other)
    cmp = @lower <=> other.lower
    return cmp unless cmp.zero?

    @upper <=> other.upper
  end
end

file = File.open('input_day20.txt', 'r')
ip_ranges = []
while (line = file.gets)
  ip_range = line.chomp.split('-').map(&:to_i)
  ip_ranges << IpRange.new(ip_range[0], ip_range[1])
end
file.close

current_ip = 0
first_valid_ip = 0
first_found = false
valid_ip_count = 0
ip_ranges.sort.each do |range_ip|
  if range_ip.lower > current_ip
    unless first_found
      first_valid_ip = current_ip
      first_found = true
    end
    valid_ip_count += range_ip.lower - current_ip
  end
  current_ip = [current_ip, range_ip.upper + 1].max
end
valid_ip_count += 4_294_967_295 - current_ip + 1
puts first_valid_ip
puts valid_ip_count
