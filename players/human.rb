class Human < Player
  VALID_INPUT = {
    r: :rock,
    p: :paper,
    s: :scissors,
    q: :quit
  }

  def play_turn
    return move_set[game.turn] if move_set[game.turn]
    loop do
      puts "Select your move with 'r', 'p', 's', or quit with 'q'"
      input = gets.chomp.downcase
      move = VALID_INPUT[input.to_sym]
      return move if move
      puts "INVALID INPUT TERMINATED. Please think again!"
    end
  end
end
