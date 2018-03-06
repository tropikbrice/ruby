#!/usr/bin/env ruby
starTime = Time.now
puts starTime

require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pry'
require 'uri'
require 'csv'

def get_contact_of_a_lawyer(page_url)
	# get contact information for one lawyer from his url
	# parse html
	# https://stackoverflow.com/questions/39408402/in-ruby-how-to-convert-special-characters-like-%C3%AB-%C3%A0-%C3%A9-%C3%A4-all-to-e-a-e-a/39408577
	page_url=page_url.unicode_normalize(:nfkd).encode('ASCII', replace: '')
	page = Nokogiri::HTML(open(page_url));

	#MAIN OFFICE
	#get name of the main office
	nameOffice = page.xpath('//span[@itemprop="name"]/h1').text.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip ;
	#get adress of the main office
	streetAdress = page.xpath('//div[@class="notaireItem"]//span[@itemprop="streetAddress"]').text.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip ;
	#streetAdress = page.xpath('//div[@class="notaireItem"]//span[@itemprop="streetAddress"]').map{|x| x.text.rstrip}
	#get postCode & town
	addressLocality= page.xpath('//div[@class="notaireItem"]//span[@itemprop="addressLocality"]').text.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip ;
	postCode = addressLocality[0..4]
	town = addressLocality[6..-1]
	#get main email (if there are several emails)
	email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]//a[@href="#formContactEtude"]').text.rstrip ;
	# email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]').map{|x| x.text.rstrip[3..-1]}

	#OTHER OFFICE
	#get name of each employe lawyer of the office
	nameOtherLawyer = page.xpath('//div[@class="notaireItem secondaire"]//span[@itemprop="name"]/strong').map{|x| x.text.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip} ;
	#get email of each lawyer of the office
	emailOther = page.xpath('//div[@class="notaireItem secondaire"]//a[@class="goToMail"]').map{|x| x.text.unicode_normalize(:nfkd).encode('ASCII', replace: '').rstrip} ;

	contact = Hash.new
	contact = { :nameOffice=>nameOffice, :streetAdress=>streetAdress , :postCode=>postCode, :town=>town, :email=>email, :nameOtherLawyer=>nameOtherLawyer, :emailOther=>emailOther}

	#return nameOffice, streetAdress , postCode, town, email, nameOtherLawyer, emailOther
	# binding.pry
	return contact
end
# page_url = "https://www.immonot.com/annuaire-notaires-paris/0000014050/mes-sandra-abitbol-et-emmanuelle-le-gall-abramczyk.html"
# lawyer=get_contact_of_a_lawyer(page_url)

#########################################################################
#########################################################################
#########################################################################
#########################################################################
#get all url of lawyers for one given department
def get_all_url_of_department(page_url)
	page=page_url.unicode_normalize(:nfkd).encode('ASCII', replace: '')
	page = Nokogiri::HTML(open(page_url));

	##########################
	urlPages = page.xpath('//ul[@class="pageList pull-right"]//a') ;

	#loop on page number, working even page number =1 !!!
	urlPagesSize = (urlPages.size-1)/2
	urlPagesList = []
	urlList = []
	for i in 0..urlPagesSize-1
		urlPagesList = "https://www.immonot.com"+ urlPages[i][:href]
		urlPagesList = urlPagesList.unicode_normalize(:nfkd).encode('ASCII', replace: '')

		# urlPagesList.each do |urlToScrap|
		page2 = Nokogiri::HTML(open( urlPagesList ));

		link = page2.xpath('//div[@class="notaireItem "]//h2//a') ;
		link.each do |x|
			urlList << { nameOffice:x.text, url:"https://www.immonot.com"+ x[:href] }
		end
	end

	# binding.pry
	return urlList
end
# page_url = "https://www.immonot.com/annuaire-notaires/23/notaires-creuse-23.html"
# get_all_url_of_department(page_url)

#########################################################################
#########################################################################
#########################################################################
#########################################################################
# get urls of all french department
def get_url_of_france()
	page_url = "https://www.immonot.com/annuaire-des-notaires-de-france.html"

	scrapPage = Nokogiri::HTML(open(page_url));

	urlDpt = scrapPage.xpath('//map[@name="departements"]//area');

	urlDptList=[]
	urlDpt.each do |xdpt|
		urlDptList << { nameDpt:xdpt[:title], url:"https://www.immonot.com"+ xdpt[:href] }
	end

	# store list in csv
	CSV.open("urlDptList.csv", "wb") do |csv|
		csv << urlDptList.first.keys; # adds the attributes name on the first line
		urlDptList.each do |hash|
			csv << hash.values ;
		end
	end

	return urlDptList
end
# urlDptList=get_url_of_france()

#########################################################################
#########################################################################
#########################################################################
#########################################################################
# Final road	
def get_all_contacts_france()
	# get all url of all french department
	urlDptList=get_url_of_france()
	# ty to convert csv to array of hash
	# keys = [:nameDpt, :url]
	# urlDptList1=CSV.read('urlDptList.csv').map {|a| Hash[ keys.zip(a) ]}


	# urlDptList = [{nameDpt:"Paris", url:"https://www.immonot.com/annuaire-notaires/75/notaires-paris-75.html"}]

	# get all urls of each office for global france (each department)
	officeUrlList = []
	officeUrlList2 = []
	# binding.pry

	urlDptList.each do |urlDpt|
	# if you want to launch for just few dpt
	# for i in 3..4 do	
	# urlDpt = urlDptList[i]

	# puts urlDpt[:nameDpt] 
	# puts Time.now

	officeUrlList = { nameDpt:urlDpt[:nameDpt] , urlByEachDpt:get_all_url_of_department(urlDpt[:url])}

		# puts "--------------------------------"
		contact=[]
		officeUrlList[:urlByEachDpt].each do |x|
			contact << get_contact_of_a_lawyer(x[:url])
		end
		officeUrlList2 << {nameDpt:urlDpt[:nameDpt] , contact:contact}
	end

	return officeUrlList2
end
# officeUrlList=get_all_contacts_france();

# # Save results into Json file
# require 'json'
# File.open("scrap.json","w") do |f|
# 	f.write(officeUrlList.to_json)
# end

binding.pry

#########################################################################
#########################################################################
#########################################################################
#########################################################################
require "google_drive"
require 'gmail'

def get_contact_and_put_it_in_spreadsheet(tab,ndpt,i_start)
	# open session on googleDrive
	session = GoogleDrive::Session.from_config("client_secret.json");

	scrapFile = session.spreadsheet_by_title("_scrapLawyer");

	sheet = scrapFile.worksheets[0];

	i=i_start;
	# tab.each do |dpt|
	dpt = tab[ndpt];
		dpt[:contact].each do |dptCtc_c|
			# puts dptCtc_c[:nameOffice]
			# puts "--------------------"	
			# puts i
			# puts dptCtc_c
			# puts dptCtc_c.size
			# puts "--------------------"				
			sheet[i,1] = dpt[:nameDpt]
			sheet[i,2] = dptCtc_c[:nameOffice]
			sheet[i,3] = dptCtc_c[:streetAdress]
			sheet[i,4] = dptCtc_c[:postCode]
			sheet[i,5] = dptCtc_c[:town]
			sheet[i,6] = dptCtc_c[:email]
			sheet[i,7] = dptCtc_c[:nameOtherLawyer]
			sheet[i,8] = dptCtc_c[:emailOther]

			i += 1
		end
		i_end = i
	# end

	sheet.save
	return i_end
	# binding.pry
end

# tab = officeUrlList;
# j=2
j=4810
# ndpt=44
# for ndpt in 44 .. tab.size-1

for ndpt in 96.. 104
	j=get_contact_and_put_it_in_spreadsheet(officeUrlList,ndpt,j)
	puts j
	puts Time.now
	puts "--------------------"	
end

#########################################################################
#########################################################################
#########################################################################
#########################################################################
# Send Email to each main office email
# toDo


endTime = Time.now
puts endTime
diff= endTime - starTime
puts diff


CSV.open("trial.csv", "wb") do |csv|
	csv << [diff]
end