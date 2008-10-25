require 'rubygems'
require 'active_support'
require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'

class Sequencer < Monome::Application
	every 0.25,	:sequence
	
	on :initialize do
		@midi = LiveMIDI.new(:clock => Clock.new(30), # confusion!!!!!!!!!!
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = (0..7).map {ScrambleGrid.new(probability, 64)}
		@cursor = 0
	end
	
	on :sequence do
		device.clear
		sequences = @grids.map(&:iterate)
		sequences.each_index{|i|sequences[i].each{|n| play(n, i)}}
	end
	
	on :press do |row, column, state|
	end
	
	private
	def current_grid
		@grids[@cursor]
	end
	
	def light(note)
		grid[note % 8, note / 8] = 1
	end
	
	def play(note, channel)
		scale = MAJOR_SCALE
		light(note) if channel == @cursor
		base = 32
		octave = note / 8
		position = note % 8
		note = base + (octave * 12) + scale[position % scale.length]
		
		@midi.play(Note.new(channel, note, 1, 100))
	end
end

Sequencer.run(:device => Monome::M40h.new)
