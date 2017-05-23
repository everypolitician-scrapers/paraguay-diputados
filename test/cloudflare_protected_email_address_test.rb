# frozen_string_literal: true

require_relative './test_helper'
require_relative '../lib/cloudflare_protected_email_address'

describe CloudflareProtectedEmailAddress do
  it 'will make an obfuscated email address human readable' do
    CloudflareProtectedEmailAddress.new('b3d2dfd7dcc5d6c1d2f3d7dac3c6c7d2d7dcc09dd4dcc59dc3ca')
                                   .human_readable
                                   .must_equal 'aldovera@diputados.gov.py'
  end

  it 'returns the initialization email when it is not obfuscated' do
    CloudflareProtectedEmailAddress.new('aldovera@diputados.gov.py')
                                   .human_readable
                                   .must_equal 'aldovera@diputados.gov.py'
  end

  it 'returns the original string when the initialization string is not an obfuscated email' do
    CloudflareProtectedEmailAddress.new('xyz789')
                                   .human_readable
                                   .must_equal 'xyz789'
  end
end
