class BeatFavorite < Player

  def play_turn
    if @game.first_turn?
      move_set[@game.turn] = MOVES.sample
    else
      move = Game::MOVE_HIERARCHY.invert[@game.most_common_move_for(0)]
      move_set[@game.turn] = move
    end
  end
end
