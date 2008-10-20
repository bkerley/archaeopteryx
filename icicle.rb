require 'rubygems'
require 'active_support'
require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'
require 'scramble_grid'

class Icicle < Monome::Application
	every 0.25,	:sequence
	
	on :initialize do
		probability = ARGV[0].to_f || 0.75
		@midi = LiveMIDI.new(:clock => Clock.new(30), # confusion!!!!!!!!!!
		                     :logging => false,
		                     :midi_destination => 0)
		@grids = (0..7).map {ScrambleGrid.new(probability, 64)}
		@cursor = 0
		@sequence = []
	end
	
	on :sequence do
		device.clear
		sequences = @grids.map(&:iterate)
		sequences.each_index{|i|sequences[i].each{|n| play(n, i)}}
	end
	
	on :press do |row, column, state|
		next if column == 0
		next unless state == 1
		note = (row * 8) + column
		play(note)
		current_grid.add_sequence(note)
	end
	
	on :press do |row, column, state|
		next unless column == 0
		next unless state == 1
		case row
		when 0
			current_grid.clear_sequence
			puts "cleared sequence"
			device.unclear
		when 1
			current_grid.scramble
			puts "scrambled grid"
			null_light
		when 2
			@cursor = (@cursor - 1) % @grids.length
			puts "grid #{@cursor}"
		when 3
			@cursor = (@cursor + 1) % @grids.length
			puts "grid #{@cursor}"
		when 4
			current_grid.scramble_to 0.0
			puts "scrambled 0.0"
			null_light
		when 5
			current_grid.scramble_to 0.5
			puts "scrambled 0.5"
			null_light
		when 6
			current_grid.scramble_to 0.75
			puts "scrambled 0.75"
			null_light
		when 7
			current_grid.scramble_to 1.0
			puts "scrambled 1.0"
			null_light
		end
	end
	
	private
	def current_grid
		@grids[@cursor]
	end
	
	def null_light
		64.times do |i|
			light(i) if current_grid.next(i).nil?
		end
	end
	
	def light(note)
		grid[note % 8, note / 8] = 1
	end
	
	def play(note, channel=0)
		scale = MINOR_SCALE
		light(note)
		base = 32
		octave = note / 8
		position = note % 8
		note = base + (octave * 12) + scale[position % scale.length]
		
		@midi.play(Note.new(channel, note, 1, 100))
	end
end

Icicle.run(:device => Monome::M40h.new)
