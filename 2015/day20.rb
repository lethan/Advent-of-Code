input = 34000000

class Integer
  def factors
    1.upto(Math.sqrt(self)).select {|i| (self % i).zero?}.inject([]) do |f, i|
      f << i
      f << self / i unless i == self / i
      f
    end.sort
  end
end

house_number = 0
begin
  house_number += 1
  factors = house_number.factors

  presents = 0
  factors.each do |factor|
    presents += factor*10
  end
end until presents >= input
puts house_number

house_number = 0
begin
  house_number += 1
  factors = house_number.factors

  presents = 0
  factors.each do |factor|
    presents += factor*11 if house_number / factor <= 50
  end
end until presents >= input
puts house_number
