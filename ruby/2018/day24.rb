# frozen_string_literal: true

require 'english'

class Group
  attr_accessor :units, :hit_points, :immunities, :weakness, :attack_type, :damage_points, :initiative, :selected_target

  def initialize(units, hit_points, immunities, weakness, attack_type, damage_points, initiative)
    @units = units
    @hit_points = hit_points
    @immunities = immunities
    @weakness = weakness
    @attack_type = attack_type
    @damage_points = damage_points
    @initiative = initiative
    @selected_target = nil
  end

  def effective_power
    @units * @damage_points
  end

  def received_damage(attacker)
    attacker.units * attacker.damage_points * (@weakness.include?(attacker.attack_type) ? 2 : 1) * (@immunities.include?(attacker.attack_type) ? 0 : 1)
  end

  def sort_by_effective(other)
    cmp = other.effective_power <=> effective_power
    return cmp unless cmp.zero?

    other.initiative <=> @initiative
  end

  def sort_by_received_damage(attacker, other)
    cmp = other.received_damage(attacker) <=> received_damage(attacker)
    return cmp unless cmp.zero?

    sort_by_effective(other)
  end
end

file = File.open('../../input/2018/input_day24.txt', 'r')
immune_system = []
infections = []
current_import = nil
while (line = file.gets)
  line = line.chomp
  case line
  when 'Immune System:'
    current_import = immune_system
  when 'Infection:'
    current_import = infections
  when /(?<units>\d+) units each with (?<hit_points>\d+) hit points (\((?<defense_info>.*)\))? ?with an attack that does (?<damage>\d+) (?<attack>\w+) damage at initiative (?<initiative>\d+)/
    unless current_import.nil?
      weakness = []
      immunities = []
      if $LAST_MATCH_INFO[:defense_info]
        $LAST_MATCH_INFO[:defense_info].split('; ').each do |defense|
          tmp = defense.split(' to ')
          case tmp[0]
          when 'weak'
            weakness.push(*tmp.last.split(', '))
          when 'immune'
            immunities.push(*tmp.last.split(', '))
          end
        end
      end

      current_import << Group.new($LAST_MATCH_INFO[:units].to_i, $LAST_MATCH_INFO[:hit_points].to_i, immunities, weakness, $LAST_MATCH_INFO[:attack], $LAST_MATCH_INFO[:damage].to_i, $LAST_MATCH_INFO[:initiative].to_i)
    end
  end
end
file.close

def combat(immune_system, infections, boost)
  immune_system.each do |immune|
    immune.damage_points += boost
  end
  selected_targets = 1
  killed_units = 1
  winner = :stallmate
  until immune_system.empty? || infections.empty? || selected_targets.zero? || killed_units.zero?
    selected_targets = 0
    possible_targets = infections.dup
    immune_system.sort(&:sort_by_effective).each do |immune|
      target = possible_targets.min { |a, b| a.sort_by_received_damage(immune, b) }
      next if target&.received_damage(immune)&.zero?

      immune.selected_target = target
      possible_targets -= [target]
      selected_targets += 1
    end

    possible_targets = immune_system.dup
    infections.sort(&:sort_by_effective).each do |infection|
      target = possible_targets.min { |a, b| a.sort_by_received_damage(infection, b) }
      next if target&.received_damage(infection)&.zero?

      infection.selected_target = target
      possible_targets -= [target]
      selected_targets += 1
    end

    deaths = []
    killed_units = 0
    combatants = immune_system + infections
    combatants.sort_by(&:initiative).reverse_each do |combatant|
      if combatant.selected_target.nil? || !combatant.units.positive?
        combatant.selected_target = nil
        next
      end

      combatant.selected_target.units -= combatant.selected_target.received_damage(combatant) / combatant.selected_target.hit_points
      killed_units += combatant.selected_target.received_damage(combatant) / combatant.selected_target.hit_points
      deaths << combatant.selected_target unless combatant.selected_target.units.positive?
      combatant.selected_target = nil
    end
    immune_system -= deaths
    infections -= deaths
  end

  winner = :immune_system if infections.empty?
  winner = :infections if immune_system.empty?
  [(immune_system + infections).sum(&:units), winner]
end

boost = 0
last_winner = nil
result = nil
until last_winner == :immune_system
  new_immune_system = immune_system.map(&:dup)
  new_infections = infections.map(&:dup)
  result = combat(new_immune_system, new_infections, boost)
  puts result.first if boost.zero?
  last_winner = result.last
  boost += 1
end
puts result.first
