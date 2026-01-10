class GameController < ApplicationController
  def show
    game = load_game
    state = Engine::Game.replay(game.fetch("initial_state"), game.fetch("actions"))

    @turn = state.fetch("turn")
    @current_player = Engine::Game.current_player_name(state)
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
    names = params.fetch(:players, "").split(",")
    initial_state = Engine::Game.new_game(names)

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
    return game if game.present? && game["initial_state"].present? && game["actions"].is_a?(Array)

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
end
