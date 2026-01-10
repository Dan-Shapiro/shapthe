class GameController < ApplicationController
  def show
    game = load_game

    @turn = game.turn
    @current_player = game.current_player_name
    @players = game.players
  end

  def end_turn
    game = load_game
    game = game.end_turn
    save_game(game)
    redirect_to root_path
  end

  private

  def load_game
    data = session[:game]

    if data.nil?
      game = Engine::Game.new(players: [ "Dan", "Kris" ], turn: 1, current_player_index: 0)
      save_game(game)
      return game
    end

    Engine::Game.from_h(data)
  end

  def save_game(game)
    session[:game] = game.to_h
  end
end
