Rails.application.routes.draw do
  root "game#show"
  post "/end_turn", to: "game#end_turn"
end
