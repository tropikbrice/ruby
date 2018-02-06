require 'rubygems'
require 'nokogiri' 
require 'open-uri'
require 'pry'
require 'uri'

def get_contact_of_a_lawyer(page_url)
	# get contact information for one lawyer from his url
	# parse html
	binding.pry

	page = Nokogiri::HTML(open(page_url));

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
	email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]//a[@href="#formContactEtude"]').text.rstrip
	# email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]').map{|x| x.text.rstrip[3..-1]}

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

page_url = "https://www.immonot.com/annuaire-notaires-digne-les-bains/0000010171/mes-veronique-guerin-wacongne-christian-nicolle-et-dominique-balcet.html"
page_url="https://www.immonot.com/annuaire-notaires-libourne/0000011633/mes-i\u00F1igo-sanchez-ortiz-marjorie-jordana-goumard-julie-garrau-mounet-et-vanessa-sobel-douvrandelle.html"

lawyer=get_contact_of_a_lawyer(page_url)
binding.pry

# page = Nokogiri::HTML(open(page_url));

# email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]//a[@href="#formContactEtude"]')
# email = page.xpath('//div[@class="notaireItem"]//span[@itemprop="email"]').map{|x| x.text.rstrip[3..-1]}