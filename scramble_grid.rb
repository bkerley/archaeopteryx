class ScrambleGrid
	def initialize(probability, count)
		@count = count
		@probability = probability
		scramble
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