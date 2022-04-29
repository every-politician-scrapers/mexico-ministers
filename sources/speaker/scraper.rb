#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator ReplaceZeroWidthSpaces
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def holder_entries
    noko.xpath("//table[.//th[contains(.,'Año')]]//tr[td]")
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[_ img name no party dates].freeze
    end

    def raw_combo_date
      super.gsub(/Desde el (?<date>.*)/, '\k<date> - Incumbent').tidy
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
