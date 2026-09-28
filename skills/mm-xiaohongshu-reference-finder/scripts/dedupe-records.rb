#!/usr/bin/env ruby

require "json"
require "uri"

data_path = ARGV[0].to_s
query = ARGV[1].to_s.strip
abort "usage: dedupe-records.rb <records.json> <link-or-title>" if data_path.empty? || query.empty?
abort "records not found: #{data_path}" unless File.file?(data_path)

def records_from(parsed)
  return parsed if parsed.is_a?(Array)
  return parsed["records"] if parsed.is_a?(Hash) && parsed["records"].is_a?(Array)
  return parsed["data"] if parsed.is_a?(Hash) && parsed["data"].is_a?(Array)
  abort "expected a JSON array or an object containing records/data"
end

def value(record, *keys)
  keys.each { |key| return record[key] unless record[key].nil? }
  nil
end

def item_id(text)
  text.to_s[/[0-9a-f]{24}/i]&.downcase
end

def normalized_url(text)
  uri = URI.parse(text.to_s)
  return nil unless uri.is_a?(URI::HTTP)
  "#{uri.scheme.downcase}://#{uri.host.downcase}#{uri.path.sub(%r{/+$}, "")}" 
rescue URI::InvalidURIError
  nil
end

records = records_from(JSON.parse(File.read(data_path)))
query_id = item_id(query)
query_url = normalized_url(query)
query_title = query.downcase

matches = records.select do |record|
  urls = %w[url link share_url share_link].map { |key| record[key] }.compact
  record_id = value(record, "id", "note_id").to_s.downcase
  title = value(record, "title", "name").to_s.strip.downcase
  id_match = query_id && (record_id == query_id || urls.any? { |url| item_id(url) == query_id })
  url_match = query_url && urls.any? { |url| normalized_url(url) == query_url }
  title_match = !query_url && title == query_title
  id_match || url_match || title_match
end

summary = matches.map do |record|
  {
    id: value(record, "id", "note_id"),
    title: value(record, "title", "name"),
    url: value(record, "url", "link", "share_url", "share_link")
  }
end

puts JSON.pretty_generate({ duplicate: !matches.empty?, count: matches.length, matches: summary })

