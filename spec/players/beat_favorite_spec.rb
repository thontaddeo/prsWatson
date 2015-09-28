require_relative '../../game'

describe BeatLast do
  before do
    @game = Game.new(BeatLastMove)
    @player = @game.players.find { |p| p.is_a? BeatLastMove }
  end

  describe "#play_turn" do
    describe "on all turns after the first" do
      it "should select the move beating the opponents last move" do
        @game.stub(:last_move_for) { :paper }
        expect(@player.play_turn).to eq(:paper)
      end
    end

    describe "on the first turn" do
      it "should select a random move" do
        expect(@player.play_turn).to eq(:rock)
      end
    end
  end
end
