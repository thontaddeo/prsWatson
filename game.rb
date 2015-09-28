require "#{File.dirname(__FILE__)}/players/player.rb"
Dir[File.dirname(__FILE__) + '/strategies/*'].each { |file| require file }

class Game
  MOVE_HIERARCHY = {
    paper: :rock,
    rock: :scissors,
    scissors: :paper
  }

  attr_reader :players, :score, :moves, :turn
  attr_accessor :turn_limit

  # We're programmers so there is a player 0 even if that's a bit weird to
  # regular humans.
  #
  def initialize(playerTypes, turn_limit=nil)
    @players = playerTypes.each_with_index.map { |pt, idx| pt.new(self, idx) }
    @turn_limit = turn_limit
    #
    # Eventually make '@score' an instance of Score class.
    # For now: wins, losses, ties
    #
    @score = [0, 0, 0]
    @moves = []
    @turn = 0
  end

  # TODO: Accept an int indicating a number of turns to play.
  #
  def play!
    output "You are playing #{@players[1].class}"
    loop do
      break unless under_turn_limit?
      moves = []
      break unless @players.all? do |p|
        moves << p.play_turn
        moves.last == :quit ? false : true
      end
      end_turn(moves)
    end
    game_over
  end

  def most_common_move_for(playerNum)
    player_moves = @moves.map { |m| m[playerNum] }
    player_moves.group_by(&:itself).values.max_by(&:size).first
  end

  def last_move_for(playerNum)
    return if @turn == 0
    @moves[@turn - 1][playerNum]
  end

  def first_turn?
    @turn == 0
  end

  def under_turn_limit?
    return true unless @turn_limit
    @turn_limit > @turn
  end

  def end_turn(moves)
    save_moves moves
    select_turn_winner @moves[@turn]
    @turn += 1
  end

  def winner_for(turn)
    return if !@moves[turn] || @moves[turn][0] == @moves[turn][1]
    (MOVE_HIERARCHY[moves[turn][0]] == moves[turn][1]) ? 0 : 1
  end

  private

  def save_moves(moves)
    @moves[@turn] = []
    moves.each_with_index { |m, i| @moves[@turn] << m }
  end

  def select_turn_winner(moves)
    output "You chose #{moves[0]} and your opponent chose #{moves[1]}"
    if moves[0] == moves[1]
      output 'It\'s a tie! ¯\(°_o)/¯'
      @score[2] += 1
    elsif MOVE_HIERARCHY[moves[0]] == moves[1]
      output "Congratulations! You are winner! ha ha ha"
      @score[0] += 1
    else
      output "Sorry! You lose!"
      @score[1] += 1
    end
  end

  # Note: '#output' wouldn't exist within this class normally.
  #
  def output(text)
    return if ENV["environment"] == "test"
    puts text
  end

  def game_over
    output "GAME OVER"
    output "Wins: #{@score[0]} / Losses: #{@score[1]} / Ties: #{@score[2]}"
    true
  end
end
