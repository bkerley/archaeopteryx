require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'
require 'scramble_grid'

class Icicle < Monome::Application
	every 0.5,	:metronome
	every 0.25,	:sequence
	
	on :initialize do
		probability = ARGV[0].to_f || 0.75
		@midi = LiveMIDI.new(:clock => Clock.new(30), # confusion!!!!!!!!!!
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = ScrambleGrid.new(probability, 64)
		@sequence = []
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
			device.unclear
		when 1
			@grids.scramble
			puts "scrambled grid"
			null_light
		when 2
			@metronome = !@metronome
			puts "metronome is #{@metronome ? 'GO' : 'off'}"
		when 4
			@grids.scramble_to 0.0
			puts "scrambled 0.0"
			null_light
		when 5
			@grids.scramble_to 0.5
			puts "scrambled 0.5"
			null_light
		when 6
			@grids.scramble_to 0.75
			puts "scrambled 0.75"
			null_light
		when 7
			@grids.scramble_to 1.0
			puts "scrambled 1.0"
			null_light
		end
	end
	
	private
	def null_light
		64.times do |i|
			light(i) if @grids.next(i).nil?
		end
	end
	
	def light(note)
		grid[note % 8, note / 8] = 1
	end
	
	def play(note)
		scale = MINOR_SCALE
		light(note)
		base = 32
		octave = note / 8
		position = note % 8
		note = base + (octave * 12) + scale[position % scale.length]
		
		@midi.play(Note.new(0, note, 1, 100))
	end
end

Icicle.run(:device => Monome::M40h.new)
