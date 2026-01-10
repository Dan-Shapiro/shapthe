class GameController < ApplicationController
  def show
    game = load_game
    state = Engine::Game.replay(game.fetch("initial_state"), game.fetch("actions"))

    @seed = state.fetch("seed")
    @debug_roll = Engine::Game.debug_roll(state)

    @turn = state.fetch("turn")
    @current_player = Engine::Game.current_player_name(state)
    @xurrent_player_index = state.fetch("current_player_index")
    @players = state.fetch("players")

    @action_count = game.fetch("actions").length
  end

  def end_turn
    game = load_game
    append_action!(game, { "type" => "END_TURN" })
    save_game(game)
    redirect_to root_path
  end

  def new_game
    raw_players = params.fetch(:players, {}).values
    initial_state = Engine::Game.new_game(raw_players)

    game = {
      "initial_state" => initial_state,
      "actions" => []
    }

    save_game(game)
    redirect_to root_path
  rescue ArgumentError => e
    flash[:alert] = e.message
    redirect_to root_path
  end

  private

  def load_game
    game = session[:game]

    if game.present? && game["initial_state"].present? && game["actions"].is_a?(Array)
      normalize_state!(game["initial_state"])
      session[:game] = game
      return game
    end

    # default game
    initial_state = Engine::Game.new_game([ "Dan", "Kris" ])
    game = { "initial_state" => initial_state, "actions" => [] }
    save_game(game)
    game
  end

  def save_game(game)
    session[:game] = game
  end

  def append_action!(game, action)
    unless Engine::Game.valid_action?(action)
      raise ArgumentError, "Invalid action"
    end

    game["actions"] << action
  end

  def normalize_state!(state)
    state["seed"] ||= Random.new_seed

    if state["players"].is_a?(Array) && state["players"].first.is_a?(String)
      state["players"] = state["players"].map do |name|
        {
          "name" => name,
          "faction" => "Nordic",
          "mat" => "Industrial"
        }
      end
    end
  end
end
