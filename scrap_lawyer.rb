#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pry'

def get_email_of_a_lawyer(page_url)
	# parse html
	page = Nokogiri::HTML(open(page_url))

	#get directly name of office
	name_office = page.xpath('//span[@itemprop="name"]/h1').text.rstrip

	#get name of each lawyer
	name_lawyer = page.xpath('//span[@itemprop="name"]/strong').map{|x| x.text.rstrip}

	email = page.xpath('//a[@class="goToMail"]').map{|x| x.text.rstrip}

	binding.pry
	puts tt #, "----", email, "-----", "name_lawyer"
end

page_url = "https://www.immonot.com/annuaire-notaires-paris/0000014050/mes-sandra-abitbol-et-emmanuelle-le-gall-abramczyk.html"

get_email_of_a_lawyer(page_url)