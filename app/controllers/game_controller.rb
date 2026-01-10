class GameController < ApplicationController
  def show
    game = load_game

    @turn = game.turn
    @current_player = game.current_player_name
    @players = game.players
  end

  private

  def load_game
    data = session[:game]

    if data.nil?
      game = Engine::Game.new(players: [ "Dan", "Kris" ], turn: 1, current_player_index: 0)
      session[:game] = game.to_h
      return game
    end

    Engine::Game.from_h(data)
  end
end
