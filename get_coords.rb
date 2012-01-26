#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'rest_client'
require 'json'
require 'pp'

API_KEY = ''

%w{Südvorstadt
Zentrum-Süd
Zentrum
Zentrum-Südost
Zentrum-West
Zentrum-Ost
Plagwitz
Zentrum-Nordwest
Gohlis-Süd
Zentrum-Nord
Schleußig
Altlindenau
Eutritzsch
Connewitz
Stötteritz
Neustadt-Neuschönefeld
Reudnitz-Thonberg
Heiterblick
Böhlitz-Ehrenberg
Holzhausen
Burghausen
Lindenau}.each do |d|
coords = RestClient.get 'http://open.mapquestapi.com/nominatim/v1/search.php', :params => {:q => "#{d}, Leipzig", :format => "json"}
coords = JSON.parse(coords)
	coords.each do |c|
		puts c['display_name']
		puts c['type']

			print "#{c['lat']},"
			puts c['lon']
		puts
	end
end
