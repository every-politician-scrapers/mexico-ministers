#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator ReplaceZeroWidthSpaces
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Gobernador'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[_ _ name start end].freeze
    end

    def empty?
      (tds[2].text == tds[3].text) || (startDate[0...4].to_i < 1990)
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
