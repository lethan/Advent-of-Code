file = File.open('input_day18.txt', 'r')
program = []
while line = file.gets
  program << line
end
file.close

def run_programs(program, programs_data, type=1)
  counter = 0
  programs_data.each do |data|
    data[:program_pointer] = 0
    data[:current_sound] = 0
    data[:send_counter] = 0
    data[:status] = :running
    data[:send_data] = []
    data[:registers] = Hash.new(0)
    data[:registers]['p'] = counter
    counter += 1
  end
  still_running = true
  while still_running
    programs_data.each_with_index do |data, data_index|
      if data[:status] == :waiting
        programs_data.each_with_index do |data2, data_index2|
          if data_index != data_index2
            data[:status] = :running if !data2[:send_data].empty?
          end
        end
      end
      while data[:status] == :running
        instruction = program[data[:program_pointer]].split(' ')

        case instruction[0]
        when 'set'
          data[:registers][instruction[1]] = instruction[2].to_i != 0 ? instruction[2].to_i : data[:registers][instruction[2]]
          data[:program_pointer] += 1
        when 'mul'
          data[:registers][instruction[1]] = data[:registers][instruction[1]] * instruction[2].to_i
          data[:program_pointer] += 1
        when 'jgz'
          if instruction[1].to_i > 0 || data[:registers][instruction[1]] > 0
            data[:program_pointer] += instruction[2].to_i != 0 ? instruction[2].to_i : data[:registers][instruction[2]]
          else
            data[:program_pointer] += 1
          end
        when 'add'
          data[:registers][instruction[1]] += instruction[2].to_i != 0 ? instruction[2].to_i : data[:registers][instruction[2]]
          data[:program_pointer] += 1
        when 'mod'
          data[:registers][instruction[1]] %= instruction[2].to_i != 0 ? instruction[2].to_i : data[:registers][instruction[2]]
          data[:program_pointer] += 1
        when 'snd'
          if type == 1
            data[:current_sound] = data[:registers][instruction[1]]
          end
          if type == 2
            data[:send_counter] += 1
            data[:send_data] << (instruction[1].to_i == 0 ? data[:registers][instruction[1]] : instruction[1].to_i)
          end
          data[:program_pointer] += 1
        when 'rcv'
          if type == 1
            data[:status] = :stopped
          end
          if type == 2
            programs_data.each_with_index do |data2, data_index2|
              if data_index != data_index2
                if data2[:send_data].empty?
                  data[:status] = :waiting
                else
                  data[:registers][instruction[1]] = data2[:send_data].shift
                  data[:status] = :running
                  data[:program_pointer] += 1
                  break
                end
              end
            end
          end
        else
          puts "Unknown operation: #{instruction[0]}: #{instruction}"
          puts data.inspect
          data[:status] = :stopped
        end

        data[:status] = :stopped if data[:program_pointer] < 0 || data[:program_pointer] >= program.length
      end
    end
    all_stopped = true
    programs_data.each_with_index do |data, data_index|
      all_stopped = false if data[:status] == :running
      if data[:status] == :waiting
        data_waiting = false
        programs_data.each_with_index do |data2, data_index2|
          if data_index != data_index2
            data_waiting = true if !data2[:send_data].empty?
          end
        end
        all_stopped = false if data_waiting
      end
    end
    still_running = false if all_stopped
  end
  output = 0
  if type == 1
    output = programs_data.first[:current_sound]
  end
  if type == 2
    output = programs_data[1][:send_counter]
  end
  output
end

puts run_programs(program, [Hash.new])
puts run_programs(program, [Hash.new, Hash.new], 2)
