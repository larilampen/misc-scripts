require 'roo'

# This is a Ruby script for users of the Mintos P2P lending platform
# (https://www.mintos.com/en/). The platform lets you save a list of your
# investments (or the results of any loan search) into an Excel file.
# This script reads that file, analyzes it and prints out some basic
# information to stdout.
#
# The 'roo' gem must be installed to use this script.
#
# Usage: ruby mintos-summary.rb [file.xslx]
#
# The filename defaults to "my-investments.xlsx", the default name set by Mintos.
#
# Lari Lampen / 2016

if ARGV.length > 0
  inputfile = ARGV.first
else
  inputfile = './my-investments.xlsx'
end

sheet = Roo::Spreadsheet.open(inputfile)

fields_show = {orig: 'Loan Originator', bb: 'Buyback Guarantee',
  rate: 'Interest Rate', type: 'Loan Type', stat: 'Status',
  country: 'Country'}

fields_hide = {outstanding: 'Outstanding Principal'}

rows = sheet.parse(fields_show.merge(fields_hide))

hist = {}
tot = {}
weighted = 0
total = 0
fields_show.each_key do |field|
  hist[field] = {}
  tot[field] = 0
end

rows.shift
rows.each do |row|
  os = row[:outstanding].to_f
  rate = row[:rate].to_f
  weighted += os*rate
  total += os
  row.each do |field, val|
    next unless fields_show.key? field
    hist[field][val] = 0 unless hist[field].key? val
    hist[field][val] += os
    tot[field] += os
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
