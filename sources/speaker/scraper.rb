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
      %w[_ col  img name no dates].freeze
    end

    # Different tables have different numbers of columns
    def name_cell
      tds[-4]
    end

    def combo_date_cell
      tds[-2]
    end

    def raw_combo_date
      super.gsub(/Desde el (?<date>.*)/, '\k<date> -').tidy
    end

    def combo_date
      super rescue binding.pry
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
