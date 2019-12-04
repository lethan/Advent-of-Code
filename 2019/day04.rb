# frozen_string_literal: true

start_point = '206938'
end_point = '679128'
start_values = start_point.split('').map(&:to_i)
end_values = end_point.split('').map(&:to_i)

passwords = 0
reduced_passwords = 0
(start_values[0]..end_values[0]).each do |first|
  (first..9).each do |second|
    break if first == end_values[0] && second > end_values[1]

    (second..9).each do |third|
      break if first == end_values[0] && second == end_values[1] && third > end_values[2]

      (third..9).each do |fourth|
        break if first == end_values[0] && second == end_values[1] && third == end_values[2] && fourth > end_values[3]

        (fourth..9).each do |fifth|
          break if first == end_values[0] && second == end_values[1] && third == end_values[2] && fourth == end_values[3] && fifth > end_values[4]

          (fifth..9).each do |sixth|
            break if first == end_values[0] && second == end_values[1] && third == end_values[2] && fourth == end_values[3] && fifth == end_values[4] && sixth > end_values[5]

            if first == second || second == third || third == fourth || fourth == fifth || fifth == sixth
              passwords += 1
              reduced_passwords += 1 if (first == second && second != third) || (first != second && second == third && third != fourth) || (second != third && third == fourth && fourth != fifth) || (third != fourth && fourth == fifth && fifth != sixth) || (fourth != fifth && fifth == sixth)
            end
          end
        end
      end
    end
  end
end
puts passwords
puts reduced_passwords
