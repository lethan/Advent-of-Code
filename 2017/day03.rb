input = 312051

def steps(input)
  width = 0
  height = 0
  current_direction = 0
  minX = 0
  maxX = 0
  minY = 0
  maxY = 0
  currentX = 0
  currentY = 0
  new_direction = false
  1.upto(input-1) do |number|
    case current_direction
    when 0
      currentX += 1
    when 1
      currentY += 1
    when 2
      currentX -= 1
    when 3
      currentY -= 1
    end
    minX = currentX if currentX < minX
    maxX = currentX if currentX > maxX
    minY = currentY if currentY < minY
    maxY = currentY if currentY > maxY
    if maxX - minX > width
      width = maxX - minX
      new_direction = true
    end
    if maxY - minY > height
      height = maxY - minY
      new_direction = true
    end
    if new_direction
      current_direction = (current_direction + 1) % 4
      new_direction = false
    end
  end
  currentX.abs + currentY.abs
end

def above(value)
  width = 0
  height = 0
  current_direction = 0
  minX = 0
  maxX = 0
  minY = 0
  maxY = 0
  currentX = 0
  currentY = 0
  new_direction = false
  values = Array.new(1000) { Array.new(1000, 0)}
  values[500][500] = 1
  last_value = 1
  while last_value <= value do
    last_value = values[500+currentX][500+currentY]
    values[500+currentX-1][500+currentY-1] += last_value
    values[500+currentX-1][500+currentY] += last_value
    values[500+currentX-1][500+currentY+1] += last_value
    values[500+currentX][500+currentY-1] += last_value
    values[500+currentX][500+currentY+1] += last_value
    values[500+currentX+1][500+currentY-1] += last_value
    values[500+currentX+1][500+currentY] += last_value
    values[500+currentX+1][500+currentY+1] += last_value

    case current_direction
    when 0
      currentX += 1
    when 1
      currentY += 1
    when 2
      currentX -= 1
    when 3
      currentY -= 1
    end
    minX = currentX if currentX < minX
    maxX = currentX if currentX > maxX
    minY = currentY if currentY < minY
    maxY = currentY if currentY > maxY
    if maxX - minX > width
      width = maxX - minX
      new_direction = true
    end
    if maxY - minY > height
      height = maxY - minY
      new_direction = true
    end
    if new_direction
      current_direction = (current_direction + 1) % 4
      new_direction = false
    end
  end
  last_value
end

puts steps(input)
puts above(input)
