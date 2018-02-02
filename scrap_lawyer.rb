#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pry'

def get_email_of_a_lawyer(page_url)
	# parse html
	page = Nokogiri::HTML(open(page_url))

	#MAIN OFFICE
	#get name of the main office
	nameOffice = page.xpath('//span[@itemprop="name"]/h1').text.rstrip
	#get adress of the main office
	streetAdress = page.xpath('//div[@class="notaireItem"]//span[@itemprop="streetAddress"]').text.rstrip
	#streetAdress = page.xpath('//div[@class="notaireItem"]//span[@itemprop="streetAddress"]').map{|x| x.text.rstrip}
	#get postCode & town
	addressLocality= page.xpath('//div[@class="notaireItem"]//span[@itemprop="addressLocality"]').text.rstrip
	postCode = addressLocality[0..4]
	town = addressLocality[6..-1]
	#get main email (if there are several emails)
	email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]').map{|x| x.text.rstrip[3..-1]}

	#OTHER OFFICE
	#get name of each employe lawyer of the office
	nameOtherLawyer = page.xpath('//div[@class="notaireItem secondaire"]//span[@itemprop="name"]/strong').map{|x| x.text.rstrip}
	#get email of each lawyer of the office
	emailOther = page.xpath('//div[@class="notaireItem secondaire"]//a[@class="goToMail"]').map{|x| x.text.rstrip}

	contact = []
	contact << { :nameOffice=>nameOffice, :streetAdress=>streetAdress , :postCode=>postCode, :town=>town, :email=>email, :nameOtherLawyer=>nameOtherLawyer, :emailOther=>emailOther}

	#return nameOffice, streetAdress , postCode, town, email, nameOtherLawyer, emailOther
	return contact
end

# page_url = "https://www.immonot.com/annuaire-notaires-paris/0000014050/mes-sandra-abitbol-et-emmanuelle-le-gall-abramczyk.html"

# lawyer=get_email_of_a_lawyer(page_url)

#get all url of department
def get_all_url_of_department(page_url)
	page = Nokogiri::HTML(open(page_url))

	#to do : loop on pageList (number of page)

	#get links
	url = page.xpath('//div[@class="notaireItem "]//h2//a')

	urlList = []
	url.each do |x|
		urlList << { nameOffice:x.text, url:"https://www.immonot.com"+ x[:href] }
	end

	binding.pry
end

page_url = "https://www.immonot.com/annuaire-notaires/01/notaires-ain-01.html"
get_all_url_of_department(page_url)