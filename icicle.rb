require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'
require 'scramble_grid'

class Icicle < Monome::Application
	every 0.5,	:metronome
	every 0.25,	:sequence
	every 0.25,	:tick
	
	on :initialize do
		probability = ARGV[0].to_f || 0.75
		@midi = LiveMIDI.new(:clock => Clock.new(30), # confusion!!!!!!!!!!
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = ScrambleGrid.new(probability, 64)
		@sequence = []
	end
	
	on :tick do
		next unless @metronome
		grid[0,0] = 1
	end
	
	on :metronome do
		next unless @metronome
		play(21) #a440
	end
	
	on :sequence do
		device.clear
		new_sequence = @sequence.map do |n|
			next if n.nil?
			play(n)
			@grids.next(n)
		end
		@sequence = new_sequence.reject { |n| n.nil? }
	end
	
	on :press do |row, column, state|
		next if column == 0
		next unless state == 1
		note = (row * 8) + column
		play(note)
		@sequence << @grids.next(note)
	end
	
	on :press do |row, column, state|
		next unless column == 0
		next unless state == 1
		case row
		when 0
			@sequence = []
			puts "cleared sequence"
		when 1
			@grids.scramble
			puts "scrambled grid"
		when 2
			@metronome = !@metronome
			puts "metronome is #{@metronome ? 'GO' : 'off'}"
		end
	end
	
	private
	def play(note)
		grid[note % 8, note / 8] = 1
		@midi.play(Note.new(0, note + 48, 0.25, 100))
	end
end

Icicle.run(:device => Monome::M40h.new)
