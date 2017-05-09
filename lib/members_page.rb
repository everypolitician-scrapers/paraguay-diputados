# frozen_string_literal: true

require 'scraped'

class MembersPage < PyDeputatos::HTML
  decorator Scraped::Response::Decorator::CleanUrls

  field :members do
    noko.css('table.tex tr').drop(1).map do |row|
      MemberRow.new(response: response, noko: row)
    end
  end

  class MemberRow < PyDeputatos::HTML
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

    field :phone do
      tds[3].text.strip
    end

    field :email do
      tds[4].css('a').text.strip
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
