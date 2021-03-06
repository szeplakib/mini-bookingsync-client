class BaseModel
  def self.proxy
    raise "Called abstract method: proxy"
  end

  def self.attribute_names
    raise "Called abstract method: attribute_names"
  end

  def self.attr_accessors_for(&attrs)
    attr_names = attrs.call

    attr_names.each do |attr|
      define_method(attr.to_s) do
        @attributes[attr.to_s]
      end
    end

    attr_names.each do |attr|
      define_method("#{attr}=") do |arg|
        @attributes[attr.to_s] = arg
      end
    end
  end

  def self.all
    models_attributes = proxy.all
    models_attributes.map { |attrs| new(attrs) }
  end

  def self.find(id)
    new(proxy.find(id))
  end

  attr_reader :errors

  def initialize(attributes = {})
    attributes = attributes.first if attributes.is_a?(Array)
    @attributes = {}
    self.class.attribute_names.each do |name|
      @attributes[name] = attributes[name]
    end
  end

  def create
    response = self.class.proxy.create(@attributes)
    if response.success?
      return true
    else
      @errors = JSON.parse(response.body)
      return false
    end
  end

  def update(params)
    params.each { |k, v| @attributes[k] = v }
    response = self.class.proxy.update(id, params)
    if response.success?
      return true
    else
      @errors = JSON.parse(response.body)
      return false
    end
  end

  def destroy
    response = self.class.proxy.destroy(id)
    response.success? ? true : false
  end
end
