#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'rest_client'
require 'json'
require 'pp'

API_KEY = ''

json_districts = RestClient.get 'http://www.apileipzig.de/api/v1/district/districts', :params => {:api_key => API_KEY}

districts = {}

JSON.parse(json_districts)['data'].each do |district|
	districts[district['id']] = district['name']
end

json_branches = RestClient.get 'http://www.apileipzig.de/api/v1/mediahandbook/branches/search', :params => {:api_key => API_KEY, :internal_type => 'sub_market'}

branches = {}

JSON.parse(json_branches)['data'].each do |branch|
	branches[branch['id']] = branch['name']
end

puts branches.inspect

streets = {}
c = true
i = 0
step = 1000

while c do
json_streets = RestClient.get 'http://www.apileipzig.de/api/v1/district/streets', :params => {:api_key => API_KEY, :limit => step, :offset => i*step}

JSON.parse(json_streets)['data'].each do |street|
	streets[street['name']] = street['district_id'] if streets[street['name']].nil?
end

i += 1;

c = false if JSON.parse(json_streets)['paging']['next'].nil?

puts "processing streets chunk ##{i} (has next? => #{c})..."

end

companies = {}
c = true
i = 0
step = 100

result = {}

while c do
json_companies = RestClient.get 'http://www.apileipzig.de/api/v1/mediahandbook/companies', :params => {:api_key => API_KEY, :limit => step, :offset => i*step}

JSON.parse(json_companies)['data'].each do |company|
	unless streets[company['street']].nil?
		company_district_name = districts[streets[company['street']]]
		#count companies in district
		unless result[company_district_name].nil?
			result[company_district_name]['count'] += 1
		else
			result[company_district_name] = {'count' => 1}
		end
		#count company types in district
		unless result[company_district_name][branches[company['sub_market_id']]].nil?
			result[company_district_name][branches[company['sub_market_id']]] += 1
		else
			result[company_district_name][branches[company['sub_market_id']]] = 1
		end
	else
		puts "company ##{company['id']}: #{company['street']} not found."
	end
end

i += 1;

c = false if JSON.parse(json_companies)['paging']['next'].nil?

puts "processing companies chunk ##{i} (has next? => #{c})..."

end

pp result

print "Stadtteil,Anzahl,Branche mit den meisten Unternehmen,"
branches.each {|k,v| print "#{v},"}
puts

result.each do |name,data|
	print "#{name},"
	print "#{data['count']},"
	
	data.delete('count')
	max = 0
	n = ""
	data.each do |k,v|
		if max < v
			max = v
			name = k
		end
	end
	print "#{name},"
	
	branches.each do |k,v|
		if data.has_key?(v)
			print "#{data[v]},"
		else
			print "0,"
		end
	end
	puts
end
