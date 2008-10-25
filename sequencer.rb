require 'rubygems'
require 'active_support'
require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'

class Sequencer < Monome::Application
	every 0.25,	:sequence
	
	on :initialize do
		@midi = LiveMIDI.new(:clock => Clock.new(30),
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = (0..7).map {Array.new 8, false}
		@cursor = 0
	end
	
	on :sequence do
		device.clear
		light_hot
		@grids[@cursor].each_with_index do |c, r|
			next unless c
			play(r)
		end
		light_column @cursor
		cursor_cycle
	end
	
	on :press do |row, column, state|
		@grids[row][column] = !@grids[row][column] unless state.zero?
	end
	
	private
	def cursor_cycle
		@cursor = (@cursor + 1) % 8
	end
	
	def current_grid
		@grids[@cursor]
	end
	
	def light_hot
		@grids.each_with_index do |r, col|
			r.each_with_index do |v, row|
				next unless v
				light(row, col)
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
		base = 68
		position = 8 - button
		note = base + scale[position % scale.length]
		@midi.play(Note.new(channel, note, 1, 100))
	end
end

Sequencer.run(:device => Monome::M40h.new)
