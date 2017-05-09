# frozen_string_literal: true

require 'scraped'

# Work around broken character encoding
#   https://robots.thoughtbot.com/fight-back-utf-8-invalid-byte-sequences
# https://github.com/everypolitician/everypolitician-data/issues/34866
class String
  def coerce_utf8
    encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '').tidy
  end
end

class PyDeputatos
  class HTML < Scraped::HTML
  end
end
