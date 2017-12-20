class Particle
  include Comparable

  attr_accessor :particle_number
  attr_accessor :p_x, :p_y, :p_z, :v_x, :v_y, :v_z, :a_x, :a_y, :a_z

  def initialize(number, px, py, pz, vx, vy, vz, ax, ay, az)
    @particle_number = number
    @p_x = px
    @p_y = py
    @p_z = pz
    @v_x = vx
    @v_y = vy
    @v_z = vz
    @a_x = ax
    @a_y = ay
    @a_z = az
  end

  def <=> (other)
    acc_cmp = acc_compare other
    return acc_cmp if acc_cmp != 0
    vel_cmp = vel_compare(other)
    return vel_cmp if vel_cmp != 0
    pnt_compare other
  end

  def acc_compare(other)
    acc_distance <=> other.acc_distance
  end

  def vel_compare(other)
    accelerations = 0
    [:x,:y,:z].each do |sym|
      accelerations = calc_acc_factor(sym) if calc_acc_factor(sym) > accelerations
      accelerations = other.calc_acc_factor(sym) if other.calc_acc_factor(sym) > accelerations
    end
    vel_distance(accelerations) <=> other.vel_distance(accelerations)
  end

  def pnt_compare(other)
    accelerations = 0
    [:x,:y,:z].each do |sym|
      accelerations = calc_acc_factor(sym) if calc_acc_factor(sym) > accelerations
      accelerations = other.calc_acc_factor(sym) if other.calc_acc_factor(sym) > accelerations
    end
    accelerations += 1
    steps = 0
    [:x,:y,:z].each do |sym|
      steps = calc_vel_factor(sym, accelerations) if calc_vel_factor(sym, accelerations) > steps
      steps = other.calc_vel_factor(sym, accelerations) if other.calc_vel_factor(sym, accelerations) > steps
    end
    pnt_distance(steps + accelerations) <=> pnt_distance(steps + accelerations)
  end

  def acceleration
    [@a_x, @a_y, @a_z]
  end

  def velocity(scaled=0)
    [@v_x + scaled * @a_x, @v_y + scaled * @a_y, @v_z + scaled * @a_z]
  end

  def point(scaled=0)
    px = @p_x
    py = @p_y
    pz = @p_z
    vx = @v_x
    vy = @v_y
    vz = @v_z
    1.upto(scaled) do
      vx += @a_x
      vy += @a_y
      vy += @a_y
      px += vx
      py += vy
      pz += vz
    end
    [px, py, pz]
  end

  def acc_distance
    acceleration.map(&:abs).sum
  end

  def vel_distance(scaled=0)
    velocity(scaled).map(&:abs).sum
  end

  def pnt_distance(scaled=0)
    point(scaled).map(&:abs).sum
  end

  def tick
    @v_x += @a_x
    @v_y += @a_y
    @v_z += @a_<
    @p_x += @v_x
    @p_y += @v_y
    @p_z += @v_z
  end

  def calc_acc_factor(direction)
    accelerations = 0
    a = instance_variable_get("@a_#{direction}")
    v = instance_variable_get("@v_#{direction}")
    if a != 0
      fac = v / a
      if fac < 0
        accelerations = -fac
      end
    end
    accelerations
  end

  def calc_vel_factor(direction, offset=0)
    p = instance_variable_get("@p_#{direction}")
    a = instance_variable_get("@a_#{direction}")
    v = instance_variable_get("@v_#{direction}")
    1.upto(offset) do
      v += a
      p += v
    end
    steps = 0
    while v != 0 && p / v < 0
      steps += 1
      v += a
      p += v
    end
    steps
  end
end

file = File.open('input_day20.txt', 'r')
particles = []
particle_number = 0
while line = file.gets
  match = /p=<(-?\d+),(-?\d+),(-?\d+)>, v=<(-?\d+),(-?\d+),(-?\d+)>, a=<(-?\d+),(-?\d+),(-?\d+)>/.match(line)
  particles << Particle.new(particle_number, match[1].to_i, match[2].to_i, match[3].to_i, match[4].to_i, match[5].to_i, match[6].to_i, match[7].to_i, match[8].to_i, match[9].to_i)
  particle_number += 1
end
file.close

puts particles.sort!.first.particle_number
