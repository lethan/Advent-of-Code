class Magic
  attr_accessor :name, :cost, :damage_pr_round, :healing_pr_round, :armor_pr_round, :mana_pr_round, :rounds

  def initialize(name, cost, damage_pr_round, healing_pr_round, armor_pr_round, mana_pr_round, rounds)
    @name = name
    @cost = cost
    @damage_pr_round = damage_pr_round
    @healing_pr_round = healing_pr_round
    @armor_pr_round = armor_pr_round
    @mana_pr_round = mana_pr_round
    @rounds = rounds
  end
end

magics = []
magics << Magic.new('Magic Missile',  53, 4, 0, 0,   0, 1)
magics << Magic.new('Drain',          73, 2, 2, 0,   0, 1)
magics << Magic.new('Shield',        113, 0, 0, 7,   0, 6)
magics << Magic.new('Poison',        173, 3, 0, 0,   0, 6)
magics << Magic.new('Recharge',      229, 0, 0, 0, 101, 5)

mana = 500
hit_points = 50

def efficient_battle(magics, active_magics, mana_left, hit_points, boss_damage, boss_hit_points, score, best_score, hard_mode=false)
  return best_score if best_score && score >= best_score
  if hard_mode
    hit_points -= 1
    return best_score if hit_points <= 0
  end
  armor = 0
  damage = 0
  delete_active = []
  active_magics.each_with_index do |magic, index|
    armor += magic.armor_pr_round
    damage += magic.damage_pr_round
    hit_points += magic.healing_pr_round
    mana_left += magic.mana_pr_round
    magic.rounds -= 1
    if magic.rounds <= 0
      delete_active << index
    end
  end
  delete_active.reverse.each do |i|
    active_magics.delete_at(i)
  end
  boss_hit_points -= damage
  if boss_hit_points <= 0
    best_score = score if best_score.nil? || score < best_score
    return best_score
  end

  magics.each do |magic|
    already_active = false
    active_magics.each do |magic2|
      already_active = true if magic.name == magic2.name
    end
    if !already_active
      new_score = score + magic.cost
      new_mana_left = mana_left - magic.cost
      return best_score if new_mana_left < 0
      new_active = active_magics + [magic.dup]
      new_active.map!(&:dup)

      armor = 0
      damage = 0
      new_hit_points = hit_points
      delete_active = []

      new_active.each_with_index do |magic2, index|
        armor += magic2.armor_pr_round
        damage += magic2.damage_pr_round
        new_hit_points += magic2.healing_pr_round
        new_mana_left += magic2.mana_pr_round
        magic2.rounds -= 1
        if magic2.rounds <= 0
          delete_active << index
        end
      end
      delete_active.reverse.each do |i|
        new_active.delete_at(i)
      end
      new_boss_hit_points = boss_hit_points - damage
      if new_boss_hit_points <= 0
        best_score = new_score if best_score.nil? || new_score < best_score
        return best_score
      end

      new_hit_points -= [1, boss_damage - armor].max
      return best_score if new_hit_points <= 0

      value = efficient_battle(magics, new_active.dup, new_mana_left, new_hit_points, boss_damage, new_boss_hit_points, new_score, best_score, hard_mode)
      best_score = value if best_score.nil? || value < best_score
    end
  end
  best_score
end

file = File.open('../../input/2015/input_day22.txt', 'r')
boss_hit_points = 0
boss_damage = 0
while line = file.gets
  input = line.chomp.split(': ')
  case input[0]
  when 'Hit Points'
    boss_hit_points = input[1].to_i
  when 'Damage'
    boss_damage = input[1].to_i
  end
end
file.close

puts efficient_battle(magics, [], 500, 50, boss_damage, boss_hit_points, 0, nil)
puts efficient_battle(magics, [], 500, 50, boss_damage, boss_hit_points, 0, nil, true)
