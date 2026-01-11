Rails.application.routes.draw do
  root "game#show"
  post "/end_turn", to: "game#end_turn"
  post "/new_game", to: "game#new_game"
  post "/set_player_count", to: "game#set_player_count"
  post "/choose_column", to: "game#choose_column"
  post "/do_bottom", to: "game#do_bottom"
  post "/skip_bottom", to: "game#skip_bottom"
  post "/reset_session", to: "game#reset_session"
  get "/dev/reset", to: "game#dev_reset"
end
