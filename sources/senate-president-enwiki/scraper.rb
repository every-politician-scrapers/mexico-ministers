#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Notes'
  end

  def table_number
    2
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[name state dates].freeze
    end

    def empty?
      tds[2].text.include?('?') || too_early?
    end

    def raw_combo_date
      years = super.tidy
      years =~ /^\d{4}$/ ? "#{years} - #{years}" : years
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
