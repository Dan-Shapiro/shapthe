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

    def self.new_game(player_names)
      names = player_names.map(&:to_s).map(&:strip).reject(&:empty?)

      if names.length < 2 || names.length > 5
        raise ArgumentError, "Only supports 2-5 players."
      end

      new(players: names, turn: 1, current_player_index: 0)
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
