module Engine
  # simple deterministic RNG using a linear congruential generator (LCG)
  class Rng
    MOD = 2**32
    A = 1664525
    C = 1013904223

    attr_reader :seed

    def initialize(seed)
      @seed = Integer(seed) % MOD
      @state = @seed
    end

    def next_u32
      new_state = (A * @state + C) % MOD
      rng2 = self.class.new(@seed)
      rng2.instance_variable_set(:@state, new_state)
      [ new_state, rng2 ]
    end

    def rand(n)
      raise ArgumentError, "n must be >= 1" unless n.is_a?(Integer) && n >= 1
      x, rng2 = next_u32
      [ x % n, rng2 ]
    end
  end
end
