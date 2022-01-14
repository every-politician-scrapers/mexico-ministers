#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

require 'open-uri/cached'

class String
  def ztidy
    gsub(/[\u200B-\u200D\uFEFF]/, '').tidy
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Gobernador'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[name dates].freeze
    end

    # Awkward zero-width space in Alejandro Díaz de León
    def raw_combo_date
      super.ztidy
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
