# frozen_string_literal: true

file = File.open('../../input/2018/input_day25.txt', 'r')
points = []
while (line = file.gets)
  points << line.chomp.split(',').map(&:to_i)
end
file.close

constalations = []

points.each do |point|
  in_constalation = []
  constalations.each_with_index do |constalation, constalation_index|
    constalation.each do |constalation_point|
      if point.zip(constalation_point).map { |a| a.first - a.last }.map(&:abs).sum <= 3
        in_constalation << constalation_index
        break
      end
    end
  end
  case in_constalation.length
  when 0
    constalations << [point]
  when 1
    constalations[in_constalation.first] << point
  else
    constalations[in_constalation.first] << point
    in_constalation[1..-1].each do |index|
      constalations[in_constalation.first].push(*constalations[index])
      constalations[index] = nil
    end
    constalations.compact!
  end
end

puts constalations.length
