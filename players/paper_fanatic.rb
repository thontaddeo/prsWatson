class PaperFanatic < Player

  def initialize(game)
    @game = game
  end

  def play_turn
    MOVES[0]
  end
end
