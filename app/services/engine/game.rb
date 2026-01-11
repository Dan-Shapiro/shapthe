module Engine
  class Game
    def self.new_game(raw_players)
      players = Array(raw_players).each_with_index.map do |p, i|
        if p.is_a?(Hash)
          {
            "name" => p["name"].to_s.strip,
            "faction" => p["faction"].to_s.strip,
            "mat" => p["mat"].to_s.strip,
            "power" => 1,
            "popularity" => 1,
            "coins" => 0
          }
        else
          {
            "name" => p.to_s.strip,
            "faction" => Engine::Catalog::FACTIONS[i % Engine::Catalog::FACTIONS.length],
            "mat" => Engine::Catalog::PLAYER_MATS[i % Engine::Catalog::PLAYER_MATS.length],
            "power" => 1,
            "popularity" => 1,
            "coins" => 0
          }
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
        "turn_step" => "CHOOSE_COLUMN",
        "turn_column" => nil,
        "board" => {
          "hexes" => Engine::Board::HEXES,
          "adjacency" => Engine::Board::ADJACENCY
        },
        "pieces" => initial_pieces(players)
      }
    end

    def self.apply_action(state, action)
      type = action.fetch("type")

      case type
      when "END_TURN"
        end_turn(state)
      when "CHOOSE_COLUMN"
        choose_column(state, action)
      when "DO_BOTTOM"
        do_bottom(state)
      when "SKIP_BOTTOM"
        skip_bottom(state)
      when "CHOOSE_BOLSTER_REWARD"
        choose_bolster_reward(state, action)
      else
        raise ArgumentError, "Unknown action type: #{type}"
      end
    end

    def self.current_player(state)
      state.fetch("players").fetch(state.fetch("current_player_index"))
    end

    def self.current_player_name(state)
      player = state.fetch("players").fetch(state.fetch("current_player_index"))
      player.is_a?(Hash) ? player.fetch("name") : player
    end

    def self.current_mat_layout(state)
      mat = current_player(state).fetch("mat")
      Engine::Catalog::MAT_LAYOUTS.fetch(mat)
    end

    def self.selected_column_pair(state)
      col = state.fetch("turn_column")
      return nil if col.nil?
      current_mat_layout(state).fetch(col)
    end

    def self.replay(initial_state, actions)
      actions.reduce(initial_state) do |state, action|
        apply_action(state, migrate_action(state, action))
      end
    end

    def self.migrate_action(state, action)
      if action["type"] == "CHOOSE_TOP_ACTION"
        top = action["action"]

        layout = current_mat_layout(state)
        col = layout.index { |pair| pair["top"] == top }

        return { "type" => "CHOOSE_COLUMN", "column" => col } if col

        return { "type" => "CHOOSE_COLUMN", "column" => 0 }
      end

      action
    end

    def self.selected_top_action(state)
      pair = selected_column_pair(state)
      pair ? pair["top"] : nil
    end

    def self.selected_bottom_action(state)
      pair = selected_column_pair(state)
      pair ? pair["bottom"] : nil
    end

    def self.valid_action?(action)
      action.is_a?(Hash) && action["type"].is_a?(String)
    end

    def self.legal_actions(state)
      actions = []

      case state["turn_step"]
      when "CHOOSE_COLUMN"
        4.times do |i|
          actions << { "type" => "CHOOSE_COLUMN", "column" => i }
        end
      when "BOTTOM_OPTION"
        actions << { "type" => "DO_BOTTOM" }
        actions << { "type" => "SKIP_BOTTOM" }
      when "READY_TO_END"
        actions << { "type" => "END_TURN" }
      when "CHOOSE_BOLSTER"
        actions << { "type" => "CHOOSE_BOLSTER_REWARD", "reward" => "POWER" }
        actions << { "type" => "CHOOSE_BOLSTER_REWARD", "reward" => "POPULARITY" }
      else
        raise "Unknown turn step: #{state["turn_step"]}"
      end

      actions
    end

    def self.debug_roll(state)
      seed = state.fetch("seed") || Random.new_seed
      rng = Engine::Rng.new(seed)
      roll, _rng2 = rng.rand(1000)
      roll
    end

    def self.initial_pieces(players)
      pieces = []
      players.each_with_index do |p, i|
        home = Engine::Board::HOME_BY_FACTION.fetch(p.fetch("faction"))

        pieces << { "id" => "char_#{i}", "owner" => i, "type" => "CHARACTER", "hex" => home }

        2.times do |w|
          pieces << { "id" => "worker_#{w}", "owner" => i,  "type" => "WORKER", "hex" => home }
        end
      end
      pieces
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
        "turn_step" => "CHOOSE_COLUMN",
        "turn_column" => nil
      )
    end

    def self.choose_column(state, action)
      raise ArgumentError, "Not choosing a column right now." unless state["turn_step"] == "CHOOSE_COLUMN"

      col = Integer(action.fetch("column"))
      raise ArgumentError, "Column must be 0-3" unless (0..3).include?(col)

      next_step =
        if current_mat_layout(state).fetch(col).fetch("top") == "BOLSTER"
          "CHOOSE_BOLSTER"
        else
          "BOTTOM_OPTION"
        end

      state.merge(
        "turn_column" => col,
        "turn_step" => next_step
      )
    end

    def self.do_bottom(state)
      raise ArgumentError, "Bottom action not available right now." unless state["turn_step"] == "BOTTOM_OPTION"

      state.merge("turn_step" => "READY_TO_END")
    end

    def self.skip_bottom(state)
      raise ArgumentError, "Bottom action not available right now." unless state["turn_step"] == "BOTTOM_OPTION"
      state.merge("turn_step" => "READY_TO_END")
    end

    def self.choose_bolster_reward(state, action)
      raise ArgumentError, "Not choosing bolster reward right now." unless state["turn_step"] == "CHOOSE_BOLSTER"

      reward = action.fetch("reward")
      raise ArgumentError, "Invalid reward" unless [ "POWER", "POPULARITY" ].include?(reward)

      idx = state.fetch("current_player_index")
      players = state.fetch("players").map.with_index do |p, i|
        next p unless i == idx

        case reward
        when "POWER"
          p.merge("power" => p.fetch("power") + 2)
        when "POPULARITY"
          p.merge("popularity" => p.fetch("popularity") + 1)
        end
      end

      state.merge(
        "players" => players,
        "turn_step" => "BOTTOM_OPTION"
      )
    end
  end
end
