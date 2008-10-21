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
			@sequence = @sequence.map{|e| self.next(e)}.reject{|e|e.nil?}
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
		box = Math.sqrt(@count).round
		box.times do |row|
			box.times do |column|
				print @grid[column*box + row] ? ' ' : 'X'
			end
			puts "|"
		end
		puts "-"*box
	end
end