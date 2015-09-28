#!/usr/bin/env ruby

require_relative '../game'

# TODO: Accept cli options
#
game = Game.new([Human, StayShift])
game.play!
