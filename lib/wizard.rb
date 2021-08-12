class Wizard
  attr_accessor :current_index, :steps, :storage

  def initialize(opts = {})
    @current_index = opts[:current] || 0
    @storage = opts[:storage] || AbstractStorage.new
    @steps = []
  end

  def add_step(description)
    step = Step.new(description, storage)
    yield step if block_given?

    @steps << step
  end

  def current_step(index = current_index)
    steps[index]
  end

  def save(step = current_step)
    step.fields.each do |field|
      storage.put(field.id, field.value)
    end
  end

  def fill(field_id, value, step = current_step)
    if (field_index = step.fields.find_index { |field| field.id.to_sym == field_id.to_sym })
      step.fields[field_index].value = value
    else
      raise "There is no field with id=#{field.id}"
    end
  end

  def flush
    fields.each do |field|
      field.value = nil
      storage.remove(field.id)
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
    attr_reader :storage
    attr_accessor :description, :fields

    def initialize(description = '', storage)
      @description = description
      @storage = storage
      @fields = []
    end

    def add_field(id, opts = nil)
      field = Field.new(id, opts || {})
      yield field if block_given?
      field.value = storage.pull(field.id)
      @fields << field
    end
  end
end
