class GameController < ApplicationController
  def show
    state = load_state

    @turn = state.fetch("turn")
    @current_player = Engine::Game.current_player_name(state)
    @players = state.fetch("players")
  end

  def end_turn
    state = load_state
    state = Engine::Game.apply_action(state, { "type" => "END_TURN" })
    save_state(state)
    redirect_to root_path
  end

  def new_game
    names = params.fetch(:players, "").split(",")
    state = Engine::Game.new_game(names)
    save_state(state)
    redirect_to root_path
  rescue ArgumentError => e
    flash[:alert] = e.message
    redirect_to root_path
  end

  private

  def load_state
    state = session[:game]
    return state if state.present?

    state = Engine::Game.new_game([ "Dan", "Kris" ])
    save_state(state)
    state
  end

  def save_state(state)
    session[:game] = state
  end
end
