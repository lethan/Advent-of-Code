file = File.open('input_day19.txt', 'r')
transformations = Hash.new
reverse_transformations = Hash.new
input = ""
while line = file.gets
  match = /([a-zA-Z]+) => ([a-zA-Z]+)/.match(line)
  if match
    if transformations[match[1]].nil?
      transformations.merge!( match[1] => [] )
    end
    transformations[match[1]] << match[2]
    if reverse_transformations[match[2]].nil?
      reverse_transformations.merge!( match[2] => [] )
    end
    reverse_transformations[match[2]] << match[1]
  else
    input = line.chomp
  end
end
file.close

permutations = Hash.new(0)
transformations.keys.each do |key|
  input.enum_for(:scan,/#{key}/).map { Regexp.last_match.begin(0) }.each do |index|
    transformations[key].each do |change|
      permut = input.dup
      permut[index..index+key.length-1] = change
      permutations[permut] = 1
    end
  end
end

puts permutations.keys.length

def reverse_permutation(input, reverse_transformations, transforms, minimum)
  return transforms if input == "e"
  return nil if !minimum.nil? && minimum < transforms

  reverse_transformations.keys.sort_by(&:length).reverse.each do |key|
    input.enum_for(:scan,/#{key}/).map { Regexp.last_match.begin(0) }.each do |index|
      reverse_transformations[key].each do |change|
        permut = input.dup
        permut[index..index+key.length-1] = change
        value = reverse_permutation(permut, reverse_transformations, transforms + 1, minimum)
        if !value.nil?
          minimum = value if minimum.nil? || value < minimum
        end
      end
    end
  end
  minimum
end

puts reverse_permutation(input, reverse_transformations, 0, nil)
