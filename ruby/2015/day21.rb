class Equipment
  attr_accessor :name, :type, :cost, :damage, :armor

  def initialize(name, type, cost, damage, armor)
    @name = name
    @type = type
    @cost = cost
    @damage = damage
    @armor = armor
  end
end

equipments = []

equipments << Equipment.new('Dagger', :weapon, 8, 4, 0)
equipments << Equipment.new('Shortsword', :weapon, 10, 5, 0)
equipments << Equipment.new('Warhammer', :weapon, 25, 6, 0)
equipments << Equipment.new('Longsword', :weapon, 40, 7, 0)
equipments << Equipment.new('Greataxe', :weapon, 74, 8, 0)

equipments << Equipment.new('Leather', :armor, 13, 0, 1)
equipments << Equipment.new('Chainmail', :armor, 31, 0, 2)
equipments << Equipment.new('Splintmail', :armor, 53, 0, 3)
equipments << Equipment.new('Bandedmail', :armor, 75, 0, 4)
equipments << Equipment.new('Platemail', :armor, 102, 0, 5)

equipments << Equipment.new('Damage +1', :ring, 25, 1, 0)
equipments << Equipment.new('Damage +2', :ring, 50, 2, 0)
equipments << Equipment.new('Damage +3', :ring, 100, 3, 0)
equipments << Equipment.new('Defense +1', :ring, 20, 0, 1)
equipments << Equipment.new('Defense +2', :ring, 40, 0, 2)
equipments << Equipment.new('Defense +3', :ring, 80, 0, 3)

equipments.sort! { |a,b| a.cost <=> b.cost }

hit_points = 100

boss_hit_point = 0
boss_damage = 0
boss_armor = 0
file = File.open('../../input/2015/input_day21.txt', 'r')
while line = file.gets
  input = line.split(': ')
  case input[0]
  when 'Hit Points'
    boss_hit_point = input[1].to_i
  when 'Damage'
    boss_damage = input[1].to_i
  when 'Armor'
    boss_armor = input[1].to_i
  end
end
file.close

def valid_contents(arr)
  weapons = 0
  armor = 0
  rings = 0
  arr.each do |eq|
    case eq.type
    when :weapon
      weapons += 1
    when :armor
      armor += 1
    when :ring
      rings += 1
    end
  end
  weapons == 1 && armor <= 1 && rings <= 2
end

def beat_boss(arr, hit_points, boss_hit_point, boss_damage, boss_armor)
  damage = 0
  armor = 0
  arr.each do |eq|
    damage += eq.damage
    armor += eq.armor
  end
  damage = [1, damage - boss_armor].max
  boss_damage = [1, boss_damage - armor].max
  player_slash_rounds = (boss_hit_point + damage - 1) / damage
  boss_slash_rounds = (hit_points + boss_damage - 1) / boss_damage
  boss_slash_rounds >= player_slash_rounds
end

def cost(arr)
  return -1 if arr.empty?
  arr.map { |a| a.cost }.sum
end

cheapest = []
most_expensive = []
0.upto(equipments.length-1) do |first|
  eq1 = equipments[first]
  arr = [eq1]
  if valid_contents(arr)
    if beat_boss(arr, hit_points, boss_hit_point, boss_damage, boss_armor)
      if cost(arr) < cost(cheapest) || cost(cheapest) == -1
        cheapest = arr
      end
    else
      if cost(arr) > cost(most_expensive)
        most_expensive = arr
      end
    end
  end
  (first+1).upto(equipments.length-1) do |second|
    eq2 = equipments[second]
    arr = [eq1, eq2]
    if valid_contents(arr)
      if beat_boss(arr, hit_points, boss_hit_point, boss_damage, boss_armor)
        if cost(arr) < cost(cheapest) || cost(cheapest) == -1
          cheapest = arr
        end
      else
        if cost(arr) > cost(most_expensive)
          most_expensive = arr
        end
      end
    end
    (second+1).upto(equipments.length-1) do |third|
      eq3 = equipments[third]
      arr = [eq1, eq2, eq3]
      if valid_contents(arr)
        if beat_boss(arr, hit_points, boss_hit_point, boss_damage, boss_armor)
          if cost(arr) < cost(cheapest) || cost(cheapest) == -1
            cheapest = arr
          end
        else
          if cost(arr) > cost(most_expensive)
            most_expensive = arr
          end
        end
      end
      (third+1).upto(equipments.length-1) do |fourth|
        eq4 = equipments[fourth]
        arr = [eq1, eq2, eq3, eq4]
        if valid_contents(arr)
          if beat_boss(arr, hit_points, boss_hit_point, boss_damage, boss_armor)
            if cost(arr) < cost(cheapest) || cost(cheapest) == -1
              cheapest = arr
            end
          else
            if cost(arr) > cost(most_expensive)
              most_expensive = arr
            end
          end
        end
      end
    end
  end
end

puts cost(cheapest)
puts cost(most_expensive)
