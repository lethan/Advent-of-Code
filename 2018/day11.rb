input = 9995
serial_number = input

fuel_cells = Array.new(300) { Array.new(300, 0) }

1.upto(300) do |x|
  1.upto(300) do |y|
    rack_id = x + 10
    power_level = rack_id * y
    serial_number = 9995
    power_level += serial_number
    power_level *= rack_id
    power_level = (power_level / 100) % 10
    power_level -= 5
    fuel_cells[x - 1][y - 1] = power_level
  end
end

field_values = Array.new(300) { Array.new(300) { [] } }

1.upto(300) do |x|
  1.upto(300) do |y|
    value = 0
    1.upto([300 - x + 1, 300 - y + 1].min) do |size|
      0.upto(size - 2) do |step|
        value += fuel_cells[x - 1 + step][y - 1 + size - 1]
        value += fuel_cells[x - 1 + size - 1][y - 1 + step]
      end
      value += fuel_cells[x - 1 + size - 1][y - 1 + size - 1]
      field_values[x - 1][y - 1] << value
    end
  end
end

top_left = [0, 0]
max_value_three = -5 * 3 * 3
top_left_combination = [0, 0, 0]
max_value = -5 * 300 * 300

0.upto(field_values.length - 1) do |x|
  0.upto(field_values[x].length - 1) do |y|
    unless field_values[x][y][3 - 1].nil?
      if field_values[x][y][2] > max_value_three
        max_value_three = field_values[x][y][2]
        top_left = [x + 1, y + 1]
      end
    end
    if field_values[x][y].max > max_value
      max_value = field_values[x][y].max
      top_left_combination = [x + 1, y + 1, field_values[x][y].index(max_value) + 1]
    end
  end
end

puts top_left.join(',')
puts top_left_combination.join(',')
