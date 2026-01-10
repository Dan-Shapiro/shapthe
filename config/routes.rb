Rails.application.routes.draw do
  root "game#show"
  post "/end_turn", to: "game#end_turn"
  post "/new_game", to: "game#new_game"
  post "/set_player_count", to: "game#set_player_count"
end
