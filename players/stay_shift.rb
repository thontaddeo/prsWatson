#
# Theory: A player is likely to play their own winning hand again, and move
# to beat a winning opponent's hand.
#
# If the previous round is lost, switch to the move that beats the opponent's
# move. If the previous round is won, switch to the move that will beat the
# previous winning hand.
#
class StayShift < Player

  def play_turn
    if last_turn_won? || last_turn_lost?
      Game::MOVE_HIERARCHY[last_move]
    else
      MOVES.sample
    end
  end

  private

  def last_turn_lost?
    winner_num = game.winner_for(game.turn - 1)
    winner_num && winner_num != player_number
  end

  def last_turn_won?
    game.winner_for(game.turn - 1) == player_number
  end
end
