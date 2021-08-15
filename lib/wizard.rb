class Wizard
  attr_accessor :current_index, :steps, :storage, :attribute

  def initialize(opts = {})
    @current_index = opts[:current] || 0
    @storage = opts[:storage] || AbstractStorage.new
    @steps = []
    @attribute = {}
  end

  def create_step(label)
    Step.new(label: label, wizard: self)
  end

  def add_step(label, if_attribute = {})
    if if_attribute.nil? || is_pair_equal(if_attribute)
      step = create_step(label)
      yield step if block_given?

      @steps << step
    end
  end

  def is_pair_equal(hash)
    attribute.select { |k, _v| hash.has_key?(k) } == hash
  end

  def current_step(index = current_index)
    steps[index]
  end

  def save
    attribute.keys.each { |key| storage.put(key, attribute[key]) }
  end

  def fill(field_id, field_value)
    @attribute[field_id.to_sym] = field_value
  end

  def flush
    attribute.keys.each do |key|
      attribute[key] = nil
      storage.remove(key)
    end
  end

  def fields
    steps.map(&:fields).flatten
  end

  def last_step?
    current_index == steps.length - 1
  end

  class AbstractStorage
    def put(_key, _value)
      nil
    end

    def pull(_key)
      nil
    end

    def remove(_key)
      nil
    end

    def remove_all
      nil
    end
  end

  class SessionStorage < AbstractStorage
    attr_accessor :session

    def initialize(session)
      @session = session
    end

    def put(key, value)
      session[key.to_sym] = value
    end

    def pull(key)
      session[key.to_sym]
    end

    def remove(key)
      session.delete(key.to_sym)
    end
  end

  class Field
    attr_reader :id, :type, :label, :required, :choices
    attr_accessor :value

    def initialize(id, opts)
      @id = id
      @type = opts[:type]
      @label = opts[:label]
      @required = opts[:required] || false
      @value = opts[:value]
      @choices = []
    end

    def add_choice(opts = nil)
      choice = Choice.new(opts || {})
      @choices << choice

      choice
    end
  end

  class Choice
    attr_reader :label, :value

    def initialize(opts)
      @label = opts[:label]
      @value = opts[:value]
    end
  end

  class Step
    attr_reader :wizard
    attr_accessor :label, :fields

    def initialize(opts)
      @label = opts[:label] || ''
      @wizard = opts[:wizard]
      @fields = []
    end

    def add_field(id, opts = nil)
      field = Field.new(id, opts || {})
      yield field if block_given?
      field.value ||= wizard.storage.pull(field.id)
      wizard.attribute[field.id.to_sym] = field.value
      @fields << field
    end
  end
end
