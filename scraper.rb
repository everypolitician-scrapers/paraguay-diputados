#!/bin/env ruby
# encoding: utf-8

require 'csv'
require 'date'
require 'nokogiri'
require 'open-uri'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
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
      party_id: tds[2].text.strip,
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

scrape_list('http://www.diputados.gov.py/ww2/?pagina=dip-listado')

