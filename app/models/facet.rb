class Facet
  delegate :each, to: :@facets
  attr_reader :facets

  def initialize
    @facets = {}
  end

  def add(facets)
    facets = [facets] unless facets.is_a? Array

    facets.each do |facet|
      @facets.merge! facet
    end
  end

  def remove(facet)
    @facets.delete(facet.keys[0])
  end

  def toggle(options = {})
    name = options.fetch("name", nil)
    value = options.fetch("value", nil)
    return unless name && value

    if @facets[name][value][:selected]
      deselect(name: name, value: value)
    else
      select(name: name, value: value)
    end
  end

  def select(options = {})
    name = options.fetch("name", nil)
    value = options.fetch("value", nil)
    return unless name && value

    @facets[name][value][:selected] = true
  end

  def deselect(options = {})
    name = options.fetch("name", nil)
    value = options.fetch("value", nil)
    return unless name && value

    @facets[name][value].delete(:selected)
  end

  def selected
    selected = {}

    @facets.each do |facet, values|
      values.each do |value, properties|
        selected[facet] = value if properties[:selected]
      end
    end

    selected
  end

  def params
    { facets: selected.map { |name, value| { name: name, value: value } } }
  end
end
