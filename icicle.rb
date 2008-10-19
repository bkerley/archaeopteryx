require 'lib/archaeopteryx'
require '/Users/bkerley/Documents/ruby-monome/monome/lib/monome.rb'
clock = Clock.new(30)
midi = LiveMIDI.new(:clock => clock, # confusion!!!!!!!!!!
                     :logging => false,
                     :midi_destination => 0)

class Clock < Monome::Application
	every 0.5,	:metronome
	
	on :initialize do
		
	end
	
	on :metronome do
		midi.play(Note.new(0, 69, 0.25, 100))
	end
end