require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'


class Icicle < Monome::Application
	every 0.5,	:metronome
	
	on :initialize do
		@midi = LiveMIDI.new(:clock => Clock.new(30), # confusion!!!!!!!!!!
		                     :logging => false,
		                     :midi_destination => 0)
	end
	
	on :metronome do
		@midi.play(Note.new(0, 69, 0.25, 100))
	end
	
	on :press do |row, column, state|
		stop unless state == 1
		note = (row * 8) + column + 48
		@midi.play(Note.new(0, note, 0.25, 100))
	end
end

Icicle.run(:device => Monome::M40h.new)
