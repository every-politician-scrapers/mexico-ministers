#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//table[.//th[contains(.,'Diputado')]][position()=3]//tr[td]//td[position()=3 or position()=7]//a") +
    noko.xpath("//table[.//th[contains(.,'Diputado')]][position()=4]//tr[td]//td[position()=2 or position()=5]//a")
  end

  class Officeholder < OfficeholderBase
    def itemLabel
      noko.text.tidy
    end

    def item
      noko.attr('wikidata')
    end

    def startDate
      '2015-09-01'
    end

    def endDate
      '2018-08-31'
    end

    def empty?
      false
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
