# frozen_string_literal: true

require 'cgi'

class CloudflareProtectedEmailAddress
  def initialize(obfuscated)
    @obfuscated = obfuscated
  end

  def human_readable
    return obfuscated unless unescaped.include?('@')
    unescaped
  end

  private

  attr_accessor :obfuscated

  def components
    obfuscated.scan(/.{2}/).map(&:hex)
  end

  def obfuscated_characters
    components.drop(1)
  end

  def key
    components.first
  end

  def escaped
    obfuscated_characters.map { |char| (char ^ key).to_s(16).prepend('%') }.join
  end

  def unescaped
    CGI.unescape(escaped)
  end
end
