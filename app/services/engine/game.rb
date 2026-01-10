module Engine
  class Game
    attr_reader :turn, :current_player_index, :players

    def initialize(players:, turn: 1, current_player_index: 0)
      @players = players
      @turn = turn
      @current_player_index = current_player_index
    end

    def current_player_name
      players.fetch(current_player_index)
    end

    def end_turn
      next_index = (current_player_index + 1) % players.length
      next_turn = next_index == 0 ? turn + 1 : turn

      self.class.new(
        players: players,
        turn: next_turn,
        current_player_index: next_index
      )
    end

    # serialize to a plain hash so it can go in rails session
    def to_h
      {
        "players" => players,
        "turn" => turn,
        "current_player_index" => current_player_index
      }
    end

    def self.from_h(data)
      new(
        players: data.fetch("players"),
        turn: data.fetch("turn"),
        current_player_index: data.fetch("current_player_index")
      )
    end
  end
end
