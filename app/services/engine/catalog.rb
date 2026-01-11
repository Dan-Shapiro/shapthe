module Engine
  module Catalog
    FACTIONS = [
      "Nordic",
      "Rusviet",
      "Saxony",
      "Polania",
      "Crimea",
      "Albion",
      "Togawa"
    ].freeze

    PLAYER_MATS = [
      "Industrial",
      "Engineering",
      "Patriotic",
      "Mechanical",
      "Agricultural",
      "Militant",
      "Innovative"
    ].freeze

    TOP_ACTIONS = [
      "MOVE",
      "PRODUCE",
      "TRADE",
      "BOLSTER"
    ].freeze

    MAT_LAYOUTS = {
      "Industrial" => [
        { "top" => "BOLSTER", "bottom" => "UPGRADE"  },
        { "top" => "PRODUCE",   "bottom" => "DEPLOY"   },
        { "top" => "MOVE", "bottom" => "BUILD" },
        { "top" => "TRADE",    "bottom" => "ENLIST"  }
      ],
      "Engineering" => [
        { "top" => "PRODUCE", "bottom" => "UPGRADE"  },
        { "top" => "TRADE",   "bottom" => "DEPLOY"   },
        { "top" => "BOLSTER", "bottom" => "BUILD" },
        { "top" => "MOVE",    "bottom" => "ENLIST"  }
      ],
      "Patriotic" => [
        { "top" => "MOVE", "bottom" => "UPGRADE"  },
        { "top" => "BOLSTER",   "bottom" => "DEPLOY"   },
        { "top" => "TRADE", "bottom" => "BUILD" },
        { "top" => "PRODUCE",    "bottom" => "ENLIST"  }
      ],
      "Mechanical" => [
        { "top" => "TRADE", "bottom" => "UPGRADE"  },
        { "top" => "BOLSTER",   "bottom" => "DEPLOY"   },
        { "top" => "MOVE", "bottom" => "BUILD" },
        { "top" => "PRODUCE",    "bottom" => "ENLIST"  }
      ],
      "Agricultural" => [
        { "top" => "MOVE", "bottom" => "UPGRADE"  },
        { "top" => "TRADE",   "bottom" => "DEPLOY"   },
        { "top" => "PRODUCE", "bottom" => "BUILD" },
        { "top" => "BOLSTER",    "bottom" => "ENLIST"  }
      ],
      "Militant" => [
        { "top" => "BOLSTER", "bottom" => "UPGRADE"  },
        { "top" => "MOVE",   "bottom" => "DEPLOY"   },
        { "top" => "PRODUCE", "bottom" => "BUILD" },
        { "top" => "TRADE",    "bottom" => "ENLIST"  }
      ],
      "Innovative" => [
        { "top" => "TRADE", "bottom" => "UPGRADE"  },
        { "top" => "PRODUCE",   "bottom" => "DEPLOY"   },
        { "top" => "BOLSTER", "bottom" => "BUILD" },
        { "top" => "MOVE",    "bottom" => "ENLIST"  }
      ]
    }.freeze
  end
end
