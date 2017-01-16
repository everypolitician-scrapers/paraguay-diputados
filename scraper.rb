#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MemberPage < Scraped::HTML
  field :constituency do
    datos.xpath('.//td[contains(text(),"Departamento")]/following-sibling::td').text.tidy
  end

  field :tel do
    datos.xpath('.//td[contains(text(),"Teléfono")]/following-sibling::td').text.tidy
  end

  private

  def datos
    noko.css('table.tex').first
  end
end

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.css('table.tex tr').drop(1).map do |row|
      MemberRow.new(response: response, noko: row)
    end
  end

  class MemberRow < Scraped::HTML
    field :id do
      File.basename(tds[0].css('img/@src').text, '.jpg')
    end

    field :name do
      "#{given_name} #{family_name}"
    end

    field :sort_name do
      tds[1].css('a').text.tidy
    end

    field :family_name do
      sort_name.split(',').first.tidy
    end

    field :given_name do
      sort_name.split(',').last.tidy
    end

    field :party do
      tds[2].text.strip
    end

    field :party_id do
      tds[2].text.strip
    end

    field :email do
      tds[3].css('a').text.strip
    end

    field :image do
      tds[0].css('img/@src').text
    end

    field :source do
      tds[1].css('a/@href').text
    end

    field :term do
      '2013'
    end

    private

    def tds
      noko.css('td')
    end
  end
end

def scrape(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

start = 'http://www.diputados.gov.py/ww2/?pagina=dip-listado'
data = scrape(start => MembersPage).members.map do |mem|
  mem.to_h.merge(scrape(mem.source => MemberPage).to_h)
end
# puts data

ScraperWiki.save_sqlite(%i(id term), data)
