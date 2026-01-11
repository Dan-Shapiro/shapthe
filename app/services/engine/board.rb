module Engine
  module Board
    HEXES = [
      "A1", "A2", "A3",
      "B1", "B2", "B3",
      "C1", "C2", "C3"
    ].freeze

    ADJACENCY = {
      "A1" => [ "A2", "B1" ],
      "A2" => [ "A1", "A3", "B2" ],
      "A3" => [ "A2", "B3" ],
      "B1" => [ "A1", "B2", "C1" ],
      "B2" => [ "A2", "B1", "B3", "C2" ],
      "B3" => [ "A3", "B2", "C3" ],
      "C1" => [ "B1", "C2" ],
      "C2" => [ "C1", "B2", "C3" ],
      "C3" => [ "C2", "B3" ]
    }.freeze

    HOME_BY_FACTION = {
      "Nordic" => "A1",
      "Rusviet" => "A3",
      "Saxony" => "C1",
      "Polania" => "C3",
      "Crimea" => "B1",
      "Albion" => "B3",
      "Togawa" => "B2"
    }.freeze
  end
end
