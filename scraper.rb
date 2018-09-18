#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def scraper(pair)
  url, klass = pair.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response) rescue binding.pry
end

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :member_urls do
    noko.css('.listado_enlaces .card-title a/@href').map(&:text)
  end

  field :next_page do
    noko.css('li.next a/@href').text
  end
end

class MemberPage < Scraped::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :id do
    url.split('/').last
  end

  field :name do
    noko.css('h3.page-title').text.tidy
  end

  field :area do
    infobox.xpath('.//span[contains(text(),"Departamento:")]/following::text()').map(&:text).map(&:tidy).first
  end

  field :party do
    infobox.xpath('.//span[contains(text(),"Partido:")]/following::text()').map(&:text).map(&:tidy).first
  end

  field :email do
    # TODO: unprotect this
  end

  field :image do
    noko.css('.ccm-layout-column-inner img/@src').map(&:text).first
  end

  private

  def infobox
    noko.css('.contenido_principal')
  end
end

def member_urls_from(url)
  return [] if url.to_s.empty?

  page = scraper(url => MembersPage)
  page.member_urls + member_urls_from(page.next_page)
end

start = 'http://www.diputados.gov.py/ww5/index.php/institucion/diputados-nacionales'
data = member_urls_from(start).map do |url|
  scraper(url => MemberPage).to_h
end
data.each { |mem| puts mem.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[id], data)
