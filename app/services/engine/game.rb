module Engine
  class Game
    # --- State shape ---
    # {
    #   "players" => ["Dan", "Kris"],
    #   "turn" => 1,
    #   "current_player_index" => 0
    # }

    def self.new_game(player_names)
      names = player_names.map(&:to_s).map(&:strip).reject(&:empty?)

      if names.length < 2 || names.length > 5
        raise ArgumentError, "Only supports 2-5 players."
      end

      {
        "players" => names,
        "turn" => 1,
        "current_player_index" => 0
      }
    end

    # --- Action shape ---
    # { "type" => "END_TURN" }
    def self.apply_action(state, action)
      type = action.fetch("type")

      case type
      when "END_TURN"
        end_turn(state)
      else
        raise ArgumentError, "Unknown action type: #{type}"
      end
    end

    def self.current_player_name(state)
      state.fetch("players").fetch(state.fetch("current_player_index"))
    end

    # --- reducers ---
    def self.end_turn(state)
      players = state.fetch("players")
      cur = state.fetch("current_player_index")
      turn = state.fetch("turn")

      next_index = (cur + 1) % players.length
      next_turn = next_index == 0 ? turn + 1 : turn

      state.merge(
        "current_player_index" => next_index,
        "turn" => next_turn
      )
    end

    def self.replay(initial_state, actions)
      actions.reduce(initial_state) do |state, action|
        apply_action(state, action)
      end
    end

    def self.valid_action?(action)
      action.is_a?(Hash) && action["type"].is_a?(String)
    end
  end
end
