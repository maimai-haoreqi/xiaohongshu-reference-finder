#!/usr/bin/env ruby

require "json"

data_path = ARGV[0].to_s
query = ARGV[1].to_s.strip
limit = [[(ARGV[2] || 8).to_i, 1].max, 20].min
abort "usage: search-records.rb <records.json> <query> [limit]" if data_path.empty? || query.empty?
abort "records not found: #{data_path}" unless File.file?(data_path)

parsed = JSON.parse(File.read(data_path))
records = if parsed.is_a?(Array)
  parsed
elsif parsed.is_a?(Hash) && parsed["records"].is_a?(Array)
  parsed["records"]
elsif parsed.is_a?(Hash) && parsed["data"].is_a?(Array)
  parsed["data"]
else
  abort "expected a JSON array or an object containing records/data"
end

def value(record, *keys)
  keys.each { |key| return record[key] unless record[key].nil? }
  nil
end

terms = query.downcase.split(/[\s,，、]+/).reject(&:empty?)
ranked = records.each_with_object([]) do |record, matches|
  title = value(record, "title", "name").to_s.downcase
  tags = Array(value(record, "tags", "hashtags")).join(" ").downcase
  body = value(record, "body", "content", "description").to_s.downcase
  comments = Array(value(record, "comments_top5", "comments")).map { |comment| comment.is_a?(Hash) ? value(comment, "content", "text") : comment }.join(" ").downcase
  score = terms.sum do |term|
    (title.include?(term) ? 4 : 0) + (tags.include?(term) ? 3 : 0) + (body.include?(term) ? 2 : 0) + (comments.include?(term) ? 1 : 0)
  end
  matches << [score, record] unless score.zero?
end

results = ranked.sort_by { |score, record| [-score, value(record, "title", "name").to_s] }.first(limit).map do |score, record|
  {
    score: score,
    title: value(record, "title", "name"),
    url: value(record, "url", "link", "share_url", "share_link"),
    tags: value(record, "tags", "hashtags"),
    published_at: value(record, "published_at", "date"),
    likes: value(record, "liked_count", "likes")
  }
end

puts JSON.pretty_generate({ query: query, count: results.length, results: results })

