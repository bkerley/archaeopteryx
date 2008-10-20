class ScrambleGrid
	def initialize(probability, count)
		@count = count
		clear_sequence
		scramble_to(probability)
	end
	
	def add_sequence(cell)
		add = self.next(cell)
		@sequence << add unless add.nil?
	end
	
	def clear_sequence
		@sequence = []
	end
	
	def iterate
		returning @sequence.dup do
			@sequence = @sequence.map{|e| next(e)}.reject{|e|e.nil?}
		end
	end
	
	def next(cell)
		@grid[cell]
	end
	
	def scramble_to(p)
		@probability = p
		self.scramble
	end
	
	def scramble
		@grid = []
		@count.times do |n|
			@grid[n] = (rand() > @probability) ? nil : rand(@count)
		end
		dump
	end
	
	def dump
		@grid.each_index do |i|
			$stdout.print "#{i},#{@grid[i]}\t"
		end
		$stdout.puts
	end
end