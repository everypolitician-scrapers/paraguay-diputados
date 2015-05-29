#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'date'
require 'csv'

# require 'colorize'
# require 'pry'
# require 'csv'
# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'

@BASE = 'http://www.diputados.gov.py'

def noko_for(url)
  # url.prepend @BASE unless url.start_with? 'http:'
  # warn "Getting #{url}"
  Nokogiri::HTML(open(url).read) 
end

def datefrom(date)
  Date.parse(date)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('table.tex tr').drop(1).each do |row|
    tds = row.css('td')
    link = URI.join(url, tds[1].css('a/@href').text).to_s
    data = { 
      id: File.basename(tds[0].css('img/@src').text, '.jpg'),
      name: tds[1].css('a').text.strip,
      party: tds[2].text.strip,
      email: tds[3].css('a').text.strip,
      image: tds[0].css('img/@src').text, 
      source: link,
      term: '2013',
    }
    data[:image] &&= URI.join(url, data[:image]).to_s
    scrape_mp(link, data)
  end
end

def scrape_mp(url, data)
  noko = noko_for(url)
  datos = noko.css('table.tex').first

  data.merge!({
    constituency: datos.xpath('.//td[contains(text(),"Departamento")]/following-sibling::td').text.gsub(/[[:space:]]+/,' ').strip,
    tel: datos.xpath('.//td[contains(text(),"Teléfono")]/following-sibling::td').text.gsub(/[[:space:]]+/,' ').strip,
  })

  # puts data
  ScraperWiki.save_sqlite([:id, :term], data)

end

term = {
  id: 2013,
  name: '2013–2018',
  start_date: '2013-04-21',
}
ScraperWiki.save_sqlite([:id], term, 'terms')
scrape_list(@BASE + '/ww2/?pagina=dip-listado')

