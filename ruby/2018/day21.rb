# frozen_string_literal: true

def _addr(in_a, in_b, out_c)
  meth = "addr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] + arr[in_b]
    end
  end
  method(meth)
end

def _addi(in_a, in_b, out_c)
  meth = "addi_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] + in_b
    end
  end
  method(meth)
end

def _mulr(in_a, in_b, out_c)
  meth = "mulr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] * arr[in_b]
    end
  end
  method(meth)
end

def _muli(in_a, in_b, out_c)
  meth = "muli_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] * in_b
    end
  end
  method(meth)
end

def _banr(in_a, in_b, out_c)
  meth = "banr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] & arr[in_b]
    end
  end
  method(meth)
end

def _bani(in_a, in_b, out_c)
  meth = "bani_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] & in_b
    end
  end
  method(meth)
end

def _borr(in_a, in_b, out_c)
  meth = "borr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] | arr[in_b]
    end
  end
  method(meth)
end

def _bori(in_a, in_b, out_c)
  meth = "bori_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] | in_b
    end
  end
  method(meth)
end

def _setr(in_a, in_b, out_c)
  meth = "setr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a]
    end
  end
  method(meth)
end

def _seti(in_a, in_b, out_c)
  meth = "seti_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = in_a
    end
  end
  method(meth)
end

def _gtir(in_a, in_b, out_c)
  meth = "gtir_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = in_a > arr[in_b] ? 1 : 0
    end
  end
  method(meth)
end

def _gtri(in_a, in_b, out_c)
  meth = "gtri_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] > in_b ? 1 : 0
    end
  end
  method(meth)
end

def _gtrr(in_a, in_b, out_c)
  meth = "gtrr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] > arr[in_b] ? 1 : 0
    end
  end
  method(meth)
end

def _eqir(in_a, in_b, out_c)
  meth = "eqir_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = in_a == arr[in_b] ? 1 : 0
    end
  end
  method(meth)
end

def _eqri(in_a, in_b, out_c)
  meth = "eqri_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      arr[out_c] = arr[in_a] == in_b ? 1 : 0
    end
  end
  method(meth)
end

def _eqrr(in_a, in_b, out_c)
  meth = "eqrr_#{in_a}_#{in_b}_#{out_c}".to_sym
  unless self.class.instance_methods(false).include?(meth)
    define_method meth do |arr|
      if in_b.zero? && @eqrr_seen_stops.nil?
        @eqrr_seen_stops = []
        puts arr[in_a]
      end
      arr[out_c] = arr[in_a] == arr[in_b] ? 1 : 0
      if in_b.zero?
        if @eqrr_seen_stops.include?(arr[in_a])
          puts @eqrr_seen_stops.last
          arr[out_c] = 1
        end
        @eqrr_seen_stops << arr[in_a]
      end
    end
  end
  method(meth)
end

file = File.open('../../input/2018/input_day21.txt', 'r')
program = []
while (line = file.gets)
  program << line.chomp
end
file.close

def halt_numbers(program)
  pointer = 0
  registers = Array.new(6, 0)
  instructions = []
  program.each do |prog_line|
    instruction = prog_line.split(' ')
    case instruction[0]
    when '#ip'
      pointer = instruction[1].to_i
    when *%w[addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr]
      instructions << method("_#{instruction[0]}").call(*instruction[1..3].map(&:to_i))
    else
      puts 'UNKOWN INSTRUCTION'
    end
  end

  while (perform = instructions[registers[pointer]])
    break if registers[pointer].negative?

    perform.call(registers)
    registers[pointer] += 1
  end
end

halt_numbers(program)
