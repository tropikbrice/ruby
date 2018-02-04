#!/usr/bin/env ruby

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pry'

def get_contact_of_a_lawyer(page_url)
	# get contact information for one lawyer from his url
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

	contact = Hash.new
	contact = { :nameOffice=>nameOffice, :streetAdress=>streetAdress , :postCode=>postCode, :town=>town, :email=>email, :nameOtherLawyer=>nameOtherLawyer, :emailOther=>emailOther}

	#return nameOffice, streetAdress , postCode, town, email, nameOtherLawyer, emailOther
	# binding.pry
	return contact
end
# page_url = "https://www.immonot.com/annuaire-notaires-paris/0000014050/mes-sandra-abitbol-et-emmanuelle-le-gall-abramczyk.html"
# lawyer=get_contact_of_a_lawyer(page_url)

#get all url of lawyers for one given department
def get_all_url_of_department(page_url)
	page = Nokogiri::HTML(open(page_url))

	##########################
	urlPages = page.xpath('//ul[@class="pageList pull-right"]//a')

	#loop on page number, working even page number =1 !!!
	urlPagesSize = (urlPages.size-1)/2
	urlPagesList = []
	urlList = []
	for i in 0..urlPagesSize-1
		urlPagesList = "https://www.immonot.com"+ urlPages[i][:href]

		# urlPagesList.each do |urlToScrap|
		page2 = Nokogiri::HTML(open( urlPagesList ))

		link = page2.xpath('//div[@class="notaireItem "]//h2//a')
		link.each do |x|
			urlList << { nameOffice:x.text, url:"https://www.immonot.com"+ x[:href] }
		end
	end

	# binding.pry
	return urlList
end
# page_url = "https://www.immonot.com/annuaire-notaires/23/notaires-creuse-23.html"
# get_all_url_of_department(page_url)

# get urls of all french department
def get_url_of_france()
	page_url = "https://www.immonot.com/annuaire-des-notaires-de-france.html"

	scrapPage = Nokogiri::HTML(open(page_url))

	urlDpt = scrapPage.xpath('//map[@name="departements"]//area')

	urlDptList=[]
	urlDpt.each do |xdpt|
		urlDptList << { nameDpt:xdpt[:title], url:"https://www.immonot.com"+ xdpt[:href] }
	end

	return urlDptList
end
	# urlDptList=get_url_of_france()

# Final road	
def get_all_contacts_france()
	# get all url of all french department
	urlDptList=get_url_of_france()

	# get all urls of each office for global france (each department)
	officeUrlList = []
	officeUrlList2 = []
	# binding.pry

	# if you want to launch for just few dpt
	# for i in 3..4 do 
	urlDptList.each do |urlDpt|
		# urlDpt = urlDptList[i]
		officeUrlList = { nameDpt:urlDpt[:nameDpt] , urlByEachDpt:get_all_url_of_department(urlDpt[:url])}

		# puts "--------------------------------"
		contact=[]
		officeUrlListtt[:urlByEachDpt].each do |x|
			contact << get_contact_of_a_lawyer(x[:url])
		end
		officeUrlList2 << {nameDpt:urlDpt[:nameDpt] , contact:contact}
	end

	return officeUrlList2
end
# officeUrlList=get_all_contacts_france()