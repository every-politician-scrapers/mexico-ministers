#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'table_unspanner'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class WikiDate
  REMAP = {
    'Incumbent' => '',
  }.freeze

  def initialize(date_str)
    @date_str = date_str
  end

  def to_s
    return if date_en.to_s.empty?
    return date_obj.to_s if (date_en =~ /\d{1,2} \w+ \d{4}/) || (date_en =~ /\w+ \d{1,2}, \d{4}/)
    return date_obj.to_s[0...7] if date_en =~ /\w+ \d{4}/

    raise "Unknown date format: #{date_en}"
  end

  private

  attr_reader :date_str

  def date_obj
    @date_obj ||= Date.parse(date_en)
  end

  def date_en
    @date_en ||= REMAP.reduce(date_str) { |str, (ro, en)| str.sub(ro, en) }
  end
end

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class UnspanAllTables < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('table.wikitable').each do |table|
        unspanned_table = TableUnspanner::UnspannedTable.new(table)
        table.children = unspanned_table.nokogiri_node.children
      end
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder) }.reject(&:empty?).map(&:to_h).uniq
  end

  private

  def member_entries
    noko.xpath('//table[.//th[contains(.,"Term")]][3]//tr[td]')
  end
end

class Officeholder < Scraped::HTML
  def empty?
    dates.count < 2
  end

  field :item do
    tds[0].css('a/@wikidata').map(&:text).first
  end

  field :itemLabel do
    tds[0].text.tidy
  end

  field :startDate do
    WikiDate.new(dates[0]).to_s
  end

  field :endDate do
    WikiDate.new(dates[1]).to_s
  end

  private

  def tds
    noko.css('td')
  end

  def dates
    tds[2].text.split('–').map(&:tidy).reject { |str| str == '?' }
  end
end

url = 'https://en.wikipedia.org/wiki/President_of_the_Senate_(Mexico)'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
