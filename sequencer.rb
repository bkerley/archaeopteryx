require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'

class Sequencer < Monome::Application
	every 0.25,	:sequence
	
	on :initialize do
		@midi = LiveMIDI.new(:clock => Clock.new(30),
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = (0..15).map{(0..7).map {Array.new 8, false}}
		@octaves = Array.new(16, 5)
		@selector = 0
		@cursor = 0
	end
	
	on :sequence do
		device.clear
		light_hot
		@grids.each_with_index do |g, h|
				g[@cursor].each_with_index do |c, r|
				next unless c
				play(r,h)
			end
		end
		light 0, @cursor
		cursor_cycle
	end
	
	on :press do |row, column, state|
		next if column == 0 or state == 0
		current_grid[row][column] = !current_grid[row][column]
	end
	
	on :press do |row, column, state|
		next unless column == 0 && state == 1
		case row
		when 0
			@selector = (@selector - 1) % 16
			puts "grid #{@selector}"
		when 1
			@selector = (@selector + 1) % 16
			puts "grid #{@selector}"
		when 2
			@octaves[@selector] = @octaves[@selector] - 1
			puts "octave #{@octaves[@selector]}"
		when 3
			@octaves[@selector] = @octaves[@selector] + 1
			puts "octave #{@octaves[@selector]}"
		end
	end
	
	private
	def cursor_cycle
		@cursor = (@cursor + 1) % 8
	end
	
	def current_grid
		@grids[@selector]
	end
	
	def light_hot
		current_grid.each_with_index do |r, col|
			r.each_with_index do |v, row|
				light(row, col) if v
			end
		end
	end
	
	def light_column(column)
		8.times{ |d| light(d, column) }
	end
	
	def light(row, col)
		grid[row, col] = 1
	end
	
	def play(button, channel=1)
		scale = MINOR_SCALE + (MINOR_SCALE.map{|n|n+12})
		base = (@octaves[channel] * 12) + 4
		position = 8 - button
		note = base + scale[position % scale.length]
		@midi.play(Note.new(channel, note, 1, 100))
	end
end

Sequencer.run(:device => Monome::M40h.new)
