ENV["environment"] = "test"
require_relative "../game"

describe Game do

  before do
    @game = Game.new([Human, BeatLast])
    @human = @game.players[0]
    @ai = @game.players[1]
  end

  describe "#play!" do
    it "should quit when given the ':quit' message" do
      @human.move_set = [:quit]
      expect(@game.play!).to eq(true)
      expect(@game.turn).to eq(0)
    end

    it "should play a turn if a human makes a valid move selection" do
      @human.move_set = [:scissors]
      @game.turn_limit = 1
      expect(@game.turn).to eq(0)
      expect(@game.play!).to eq(true)
      expect(@game.turn).to eq(1)
    end
  end

  describe "#end_turn" do
    it "should update game#moves when called with a valid moveSet" do
      expect(@game.moves).to eq([])
      @game.end_turn([:paper, :rock])
      expect(@game.moves[0]).to eq([:paper, :rock])
    end

    it "should update game#turn when called with a valid moveSet" do
      expect(@game.turn).to eq(0)
      @game.end_turn([:paper, :rock])
      expect(@game.turn).to eq(1)
    end

    it "should update game#score when called with a valid moveSet" do
      @game.end_turn([:paper, :rock])
      expect(@game.moves[0]).to eq([:paper, :rock])
      expect(@game.score).to eq([1,0,0])
    end
  end

  describe "#most_common_move_for" do
    it "should return the most common of 3 moves" do
      @game.end_turn [:paper, :rock]
      @game.end_turn [:paper, :scissors]
      @game.end_turn [:scissors, :rock]
      expect(@game.most_common_move_for(0)).to eq(:paper)
    end

    it "should return the first if there is a tie between most common moves" do
      @game.end_turn [:paper, :rock]
      @game.end_turn [:paper, :scissors]
      expect(@game.most_common_move_for(0)).to eq(:paper)
    end
  end

  describe "#last_move_for" do
    it "should return correct last move for each player" do
      @game.end_turn [:scissors, :paper]
      expect(@game.last_move_for(0)).to eq(:scissors)
      expect(@game.last_move_for(1)).to eq(:paper)
    end

    it "should return nil when on turn 1" do
      expect(@game.last_move_for(0)).to eq(nil)
      expect(@game.last_move_for(1)).to eq(nil)
    end
  end

  describe "#first_turn?" do
    it "should return true on the first turn" do
      expect(@game.first_turn?).to eq(true)
    end

    it "should return false on the second turn" do
      @game.end_turn [:paper, :rock]
      expect(@game.first_turn?).to eq(false)
    end
  end

  describe "#under_turn_limit?" do
    it "should return true when no turn limit is defined" do
      expect(@game.under_turn_limit?).to eq(true)
    end

    it "should return true when under the limit" do
      @game.turn_limit = 3
      expect(@game.under_turn_limit?).to eq(true)
    end

    it "should return false when at the limit" do
      @game.turn_limit = 1
      @game.end_turn [:scissors, :rock]
      expect(@game.under_turn_limit?).to eq(false)
    end
  end

  describe "#winner_for" do
    it "should return nil if the game hasn't yet started" do
      expect(@game.winner_for(0)).to eq(nil)
    end

    it "should return nil if the turn hasn't yet been played" do
      expect(@game.winner_for(3)).to eq(nil)
    end

    it "should return the winner's number if the turn has been played" do
      @game.end_turn [:paper, :rock]
      expect(@game.winner_for(0)).to eq(0)
    end
  end

  # TODO: Test #output
end

describe BeatLast do
  before do
    @game = Game.new([Human, BeatLast])
    @human = @game.players[0]
    @ai = @game.players[1]
  end

  it "should win at least 3 games when the strategy is super-effective" do
    @human.move_set = [:paper, :paper, :rock, :rock, :rock]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[1]).to be >= 3
  end

  it "should lose at least 4 games when the strategy is not very effective :(" do
    @human.move_set = [:rock, :scissors, :paper, :rock, :scissors]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[0]).to be >= 4
  end

  describe "#play_turn" do
    describe "on the first turn" do
      it "should select a random move" do
        expect(Player::MOVES).to include(@ai.play_turn)
      end
    end

    describe "on all turns after the first" do
      it "should select the move beating the opponents last move" do
        @game.end_turn [:paper, :scissors]
        expect(@ai.play_turn).to eq(:scissors)
      end
    end
  end
end

describe BeatFavorite do
  before(:each) do
    @game = Game.new([Human, BeatFavorite])
    @human = @game.players[0]
    @ai = @game.players[1]
  end

  describe "#play_turn" do
    describe "on the first turn" do
      it "should select a random move" do
        expect(Player::MOVES).to include(@ai.play_turn)
      end
    end

    describe "after one move" do
      it "should select the move beating the opponent's only move" do
        @game.end_turn [:paper, :scissors]
        expect(@ai.play_turn).to eq(:scissors)
      end
    end
  end

  describe "after 4 moves with a clear favorite" do
    it "should beat the mode of the opponents moves" do
      @human.move_set = [:paper, :rock, :paper, :scissors]
      @game.turn_limit = 4
      @game.play!
      expect(@game.moves[3][1]).to eq(:scissors)
    end
  end

  describe "after two non-matching moves" do
    it "should beat the first of the oponents two moves" do
      @human.move_set = [:paper, :rock]
      @game.turn_limit = 2
      @game.play!
      expect(@game.moves[1][1]).to eq(:scissors)
    end
  end

  it "should win at least 3 games when the strategy is super-effective" do
    @human.move_set = [:paper, :paper, :rock, :paper, :paper]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[1]).to be >= 3
  end

  it "should lose at least 4 games when the strategy is not very effective :(" do
    @human.move_set = [:rock, :scissors, :scissors, :paper, :paper]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[0]).to be >= 4
  end
end

describe StayShift do
  before(:each) do
    @game = Game.new([Human, StayShift])
    @human = @game.players[0]
    @ai = @game.players[1]
  end

  describe "#play_turn" do
    describe "on the first turn" do
      it "should select a random move" do
        expect(Player::MOVES).to include(@ai.play_turn)
      end
    end

    describe "after a winning round" do
      it "should select the move that beats the last round's winning move" do
        @game.end_turn [:paper, :scissors]
        expect(@ai.play_turn).to eq(:paper)
      end
    end

    describe "after a losing round" do
      it "should select the move that beats the opponents last move" do
        @game.end_turn [:paper, :rock]
        expect(@ai.play_turn).to eq(:scissors)
      end
    end
  end

  it "should win at least 3 games when the strategy is super-effective" do
    @game.end_turn [:paper, :rock]
    @human.move_set = [:paper, :paper, :rock, :scissors, :paper]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[1]).to be >= 3
  end

  it "should lose at least 4 games when the strategy is not very effective :(" do
    @game.end_turn [:rock, :scissors]
    @human.move_set = [:rock, :scissors, :paper, :rock, :scissors]
    @game.turn_limit = 5
    @game.play!
    expect(@game.score[0]).to be >= 4
  end
end
