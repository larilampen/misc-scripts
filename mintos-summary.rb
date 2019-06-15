require 'roo'

# This is a Ruby script for users of the Mintos P2P lending platform
# (https://www.mintos.com/en/). The platform lets you save a list of your
# investments (or the results of any loan search) into an Excel file.
# This script reads that file, analyzes it and prints out some basic
# information to stdout.
#
# The 'roo' gem must be installed to use this script.
#
# Usage: ruby mintos-summary.rb file.xslx [file2.xslx ...]
#
# Lari Lampen / 2016

if ARGV.length > 0
  inputfile = ARGV.first
else
  puts "Usage: ruby mintos-summary.rb file.xslx [file2.xslx ...]"
  abort
end

fields_show = {orig: 'Loan Originator', bb: 'Buyback Guarantee',
  rate: 'Interest Rate', type: 'Loan Type', stat: 'Status',
  country: 'Country', term: 'Remaining Term'}

fields_hide = {outstanding: 'Outstanding Principal'}

all_fields = fields_show.merge(fields_hide)

hist = {}
tot = {}
weighted = 0
weighted_term = 0
total = 0
fields_show.each_key do |field|
  hist[field] = {}
  tot[field] = 0
end

ARGV.each do |inputfile|
  rows = Roo::Spreadsheet.open(inputfile).parse(all_fields)

  rows.shift
  rows.each do |row|
    os = row[:outstanding].to_f
    rate = row[:rate].to_f
    weighted += os*rate
    term = row[:term].to_f
    weighted_term += os*term
    total += os
    row.each do |field, val|
      next unless fields_show.key? field
      hist[field][val] = 0 unless hist[field].key? val
      hist[field][val] += os
      tot[field] += os
    end
  end
end

hist.each do |field, gram|
  puts "--- #{fields_show[field]} ---"
  gram.sort_by(&:last).reverse!.each do |k,v|
    k = k.to_s unless k.is_a? String
    pct = sprintf("%.1f%%", 100.0 * v / tot[field])
    padding = ' ' * (20-k.length)
    puts "#{k}#{padding} #{pct} (#{sprintf('%.2f',v)})"
  end
  puts
end

puts "Weighted average IR: #{weighted/total}%"
puts "Weighted average remaining term (NOT duration): #{weighted_term/total} months"
