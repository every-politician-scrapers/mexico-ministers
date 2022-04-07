#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderNonTable < OfficeholderListBase::OfficeholderBase
  def empty?
    false
  end

  def combo_date?
    true
  end

  def combo_date
    raise 'need to define a combo_date'
  end

  def name_node
    raise 'need to define a name_node'
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//table[.//th[contains(.,'Diputado')]][position()=3]//tr[td]//td[position()=3 or position()=7]//a") +
    noko.xpath("//table[.//th[contains(.,'Diputado')]][position()=4]//tr[td]//td[position()=2 or position()=5]//a")
  end

  class Officeholder < OfficeholderNonTable
    def name_node
      noko
    end

    def combo_date
      ['', '']
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
