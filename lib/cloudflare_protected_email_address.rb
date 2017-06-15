# frozen_string_literal: true

require 'cgi'

class CloudflareProtectedEmailAddress
  def initialize(obfuscated_address)
    @obfuscated_address = obfuscated_address
  end

  def human_readable
    return obfuscated_address unless unencoded_address.include?('@')
    unencoded_address
  end

  private

  attr_accessor :obfuscated_address

  def obfuscated_address_as_integers
    obfuscated_address.scan(/../).map(&:hex)
  end

  def key
    obfuscated_address_as_integers.first
  end

  def hex_encoded_address
    obfuscated_address_as_integers.drop(1).map { |char| '%%%02X' % (char ^ key) }.join
  end

  def unencoded_address
    CGI.unescape(hex_encoded_address)
  end
end
