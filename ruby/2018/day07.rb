file = File.open('../../input/2018/input_day07.txt', 'r')
input = {}
while (line = file.gets)
  match = /Step ([A-Z]) must be finished before step ([A-Z]) can begin./.match(line.strip)
  input[match[1]] = { depend_upon: [], dependants: [], working: false } if input[match[1]].nil?
  input[match[2]] = { depend_upon: [], dependants: [], working: false } if input[match[2]].nil?
  input[match[1]][:dependants] << match[2]
  input[match[2]][:depend_upon] << match[1]
end

def work_steps(dependencies, worker_count = 1, minimum_wait = 0)
  time = -1
  workers = []
  result = ''
  until dependencies.empty?
    time += 1
    workers.each_with_index do |worker, index|
      worker[:wait_time] -= 1
      next unless worker[:wait_time].zero?

      dependencies[worker[:work]][:dependants].each do |step|
        dependencies[step][:depend_upon] -= [worker[:work]]
      end
      dependencies.delete(worker[:work])
      result += worker[:work]
      workers[index] = nil
    end
    workers.compact!
    workable = dependencies.select { |_, v| v[:depend_upon].empty? && v[:working] == false }.keys.sort
    0.upto([worker_count - 1, workable.length - 1, worker_count - workers.length - 1].min) do
      work = workable.shift
      dependencies[work][:working] = true
      workers << { wait_time: work.ord - 64 + minimum_wait, work: work }
    end
  end
  [result, time]
end

puts work_steps(Marshal.load(Marshal.dump(input)))[0]
puts work_steps(Marshal.load(Marshal.dump(input)), 5, 60)[1]
