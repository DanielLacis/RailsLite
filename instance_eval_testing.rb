class Cat
  def initialize
    @hash = {}
    @flag = false
  end

  def draw(&prc)
    instance_eval(&prc)
  end

  def []=(key, value)
    @hash[key] = value
    if @flag
      puts "flag down"
      @flag = false
    end
  end

  def [](key)
    @hash[key]
  end

  def now
    @flag = true
    self
  end

end
