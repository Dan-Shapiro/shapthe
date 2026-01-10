module Engine
  class Game
    def self.new_game(raw_players)
      players = Array(raw_players).map do |p|
        if p.is_a?(Hash)
          {
            "name" => p["name"].to_s.strip,
            "faction" => p["faction"].to_s.strip,
            "mat" => p["mat"].to_s.strip
          }
        else
          { "name" => p.to_s.strip, "faction" => "", "mat" => "" }
        end
      end

      players = players.reject { |p| p["name"].empty? }

      if players.length < 2 || players.length > 7
        raise ArgumentError, "Only supports 2-7 players."
      end

      if players.any? { |p| p["faction"].empty? || p["mat"].empty? }
        raise ArgumentError, "Each player must have a faction and playmat."
      end

      factions = players.map { |p| p["faction"] }
      mats = players.map { |p| p["mat"] }
      if factions.uniq.length != factions.length
        raise ArgumentError, "Factions must be unique."
      end
      if mats.uniq.length != mats.length
        raise ArgumentError, "Player mats must be unique."
      end

      {
        "players" => players,
        "turn" => 1,
        "current_player_index" => 0,
        "seed" => Random.new_seed,
        "turn_top_action" => nil
      }
    end

    def self.apply_action(state, action)
      type = action.fetch("type")

      case type
      when "END_TURN"
        end_turn(state)
      when "CHOOSE_TOP_ACTION"
        choose_top_action(state, action)
      else
        raise ArgumentError, "Unknown action type: #{type}"
      end
    end

    def self.current_player_name(state)
      player = state.fetch("players").fetch(state.fetch("current_player_index"))
      player.is_a?(Hash) ? player.fetch("name") : player
    end

    def self.replay(initial_state, actions)
      actions.reduce(initial_state) do |state, action|
        apply_action(state, action)
      end
    end

    def self.valid_action?(action)
      action.is_a?(Hash) && action["type"].is_a?(String)
    end

    def self.debug_roll(state)
      seed = state.fetch("seed") || Random.new_seed
      rng = Engine::Rng.new(seed)
      roll, _rng2 = rng.rand(1000)
      roll
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
        "turn" => next_turn,
        "turn_top_action" => nil
      )
    end

    def self.choose_top_action(state, action)
      chosen = action.fetch("action")

      unless Engine::Catalog::TOP_ACTIONS.include?(chosen)
        raise ArgumentError, "Invalid top action: #{chosen}"
      end

      if state["turn_top_action"]
        raise ArgumentError, "Top action already chosen."
      end

      state.merge("turn_top_action" => chosen)
    end
  end
end
