class Player
  MOVES = [:paper, :rock, :scissors]

  attr_accessor :move_set
  attr_reader :game, :player_number

  def self.descendants
    ObjectSpace.each_object(Class).select { |klass| klass < self }
  end

  # TODO: Next step would be to move individual AI player types into a 'Strategy'
  # instance and use composition to inject them into #player. Using our current
  # example, we would be left with Human, and Computer Player types.
  #
  def initialize(game, player_number, move_set=[])
    @game = game
    @player_number = player_number
    @move_set = move_set
  end

  # TODO: Raise error
  def play_turn
    # Hook method must be overridden in subclasses
  end

  private

  def last_move
    game.last_move_for(player_number)
  end
end

Dir[File.dirname(__FILE__) + '/*.rb'].each {|file| require file }
