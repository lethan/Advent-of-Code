require 'english'

lines = []
file = File.open('../../input/2016/input_day21.txt', 'r')
while (input = file.gets)
  lines << input
end
file.close

def swap(password, pos1, pos2)
  tmp = password[pos1]
  password[pos1] = password[pos2]
  password[pos2] = tmp
end

def rotate(password, direction, positions)
  positions = password.length - positions if direction == :right
  positions = positions % password.length
  password.shift(positions).each do |char|
    password << char
  end
end

password = 'abcdefgh'.split('')
lines.each do |line|
  case line
  when /swap position (?<pos1>\d+) with position (?<pos2>\d+)/
    swap(password, $LAST_MATCH_INFO[:pos1].to_i, $LAST_MATCH_INFO[:pos2].to_i)
  when /swap letter (?<letter1>[a-z]) with letter (?<letter2>[a-z])/
    swap(password, password.index($LAST_MATCH_INFO[:letter1]), password.index($LAST_MATCH_INFO[:letter2]))
  when /rotate (?<direction>left|right) (?<steps>\d+) steps?/
    rotate(password, ($LAST_MATCH_INFO[:direction] == 'left' ? :left : :right), $LAST_MATCH_INFO[:steps].to_i)
  when /rotate based on position of letter (?<letter>[a-z])/
    positions = password.index($LAST_MATCH_INFO[:letter]) + 1
    positions += 1 if positions >= 5
    rotate(password, :right, positions)
  when /reverse positions (?<pos1>\d+) through (?<pos2>\d+)/
    pos1, pos2 = [$LAST_MATCH_INFO[:pos1], $LAST_MATCH_INFO[:pos2]].map(&:to_i)
    password[pos1..pos2] = password[pos1..pos2].reverse
  when /move position (?<pos1>\d+) to position (?<pos2>\d+)/
    pos1, pos2 = [$LAST_MATCH_INFO[:pos1], $LAST_MATCH_INFO[:pos2]].map(&:to_i)
    tmp = password.delete_at(pos1)
    password.insert(pos2, tmp)
  else
    puts 'UNKNOWN LINE!!!!!!!!!!!!!!!!!!!!!!!!!!'
  end
end
puts password.join

password = 'fbgdceah'.split('')
lines.reverse_each do |line|
  case line
  when /swap position (?<pos1>\d+) with position (?<pos2>\d+)/
    swap(password, $LAST_MATCH_INFO[:pos1].to_i, $LAST_MATCH_INFO[:pos2].to_i)
  when /swap letter (?<letter1>[a-z]) with letter (?<letter2>[a-z])/
    swap(password, password.index($LAST_MATCH_INFO[:letter1]), password.index($LAST_MATCH_INFO[:letter2]))
  when /rotate (?<direction>left|right) (?<steps>\d+) steps?/
    rotate(password, ($LAST_MATCH_INFO[:direction] == 'right' ? :left : :right), $LAST_MATCH_INFO[:steps].to_i)
  when /rotate based on position of letter (?<letter>[a-z])/
    positions = password.index($LAST_MATCH_INFO[:letter])
    direction = :left
    if positions.odd?
      positions = (positions + 1) / 2
      direction = :left
    else
      case positions
      when 0
        positions = 1
        direction = :left
      when 2
        positions = 2
        direction = :right
      when 4
        positions = 1
        direction = :right
      when 6
        positions = 0
      end
    end
    rotate(password, direction, positions)
  when /reverse positions (?<pos1>\d+) through (?<pos2>\d+)/
    pos1, pos2 = [$LAST_MATCH_INFO[:pos1], $LAST_MATCH_INFO[:pos2]].map(&:to_i)
    password[pos1..pos2] = password[pos1..pos2].reverse
  when /move position (?<pos1>\d+) to position (?<pos2>\d+)/
    pos1, pos2 = [$LAST_MATCH_INFO[:pos1], $LAST_MATCH_INFO[:pos2]].map(&:to_i)
    tmp = password.delete_at(pos2)
    password.insert(pos1, tmp)
  else
    puts 'UNKNOWN LINE!!!!!!!!!!!!!!!!!!!!!!!!!!'
  end
end
puts password.join
