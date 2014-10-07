# Wrapper around the session data which enforces the limit on the number of items
# per report. Controller code should read and write through this interface
# instead of the session directly.

class Cart
  attr_reader :items

  def initialize(item_ids = [])
    @items = {}
    item_ids ||= []
    add(item_ids)
  end

  def add(item_ids)
    hash = Hash[item_ids.map do |item_id|
      [item_id, SearchResult.from_cache(item_id)]
    end]
    @items.merge!(hash)
  end

  def remove(items)
    @items.except!(*items)
  end

  def dois
    @items.keys
  end

  def [](x)
    return @items[x]
  end

  def []=(x, val)
    if size < APP_CONFIG["article_limit"]
      @items[x] = val
    end
  end

  def delete(key)
    @items.delete(key)
  end

  def clone
    @items.clone
  end

  def size
    @items.length
  end

  def empty?
    size == 0
  end

  def clear
    @items = {}
  end
end
