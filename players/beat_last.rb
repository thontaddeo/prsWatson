class BeatLast < Player

  def play_turn
    if @game.first_turn?
      MOVES.sample
    else
      Game::MOVE_HIERARCHY.invert[@game.last_move_for(0)]
    end
  end
end
