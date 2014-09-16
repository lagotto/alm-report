# Wrapper around the session data which enforces the limit on the number of dois
# per report.  Controller code should read and write through this interface instead
# of the session directly.
class Cart
  attr_reader :dois

  def initialize(session_data = {})
    @dois = session_data || {}
  end

  def [](x)
    return @dois[x]
  end

  def []=(x, val)
    if size < APP_CONFIG["article_limit"]
      @dois[x] = val
    end
  end

  def delete(val)
    @dois.delete(val)
  end

  def clone
    @dois.clone
  end

  def size
    @dois.length
  end

  def empty?
    size == 0
  end

  def merge!(hash)
    @dois.merge!(hash)
  end

  def except!(keys)
    @dois.except!(*keys)
  end

  def clear
    @dois = {}
  end
end
