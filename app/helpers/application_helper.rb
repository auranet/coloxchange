module ApplicationHelper
  def button(*options)
    label = options.shift
    html_options = options.pop || {}
    class_name = html_options.delete(:class)
    class_name = "button input#{" #{class_name}" if class_name}"
    html_options[:rel] ||= html_options.delete(:name)
    content_tag(:button, "<span class=\"button-inner\"><span>#{label}</span></span><span class=\"button-right\"></span>", html_options.reverse_merge(:class => class_name, :name => 'send', :value => label))
  end

  def button_link(*options)
    html_options = options.pop
    label = options.shift
    url = options.shift
    if !url
      url = html_options
      html_options = {}
    end
    class_name = html_options.delete(:class)
    class_name = "button#{" #{class_name}" if class_name}"
    link_to("<span class=\"button-inner\"><span>#{label}</span></span><span class=\"button-right\"></span>", url, html_options.merge(:class => class_name))
  end

  def check_box_collection(record,methods)
    methods.collect{|label,method,options| "<label for=\"#{record}_#{method}\">#{check_box(record,method,options || {})} #{label}</label>"}.join('<br />')
  end

  def errors_on(record, method, prefix = nil)
    record = instance_variable_get("@#{record}") if record.is_a?(String) || record.is_a?(Symbol)
    if errors = record.errors.on(method)
      errors.collect.collect{|error| "<div class=\"field-error\">#{"#{prefix} " if prefix}#{"#{prefix ? method.to_s.humanize.downcase : method.to_s.humanize} " unless error[0, 1].upcase == error[0, 1]}#{prefix ? "#{error[0, 1].downcase}#{error[1, error.length]}" : error}</div>"}.join("\n")
    end if record
  end

  def hide_if(condition)
    condition ? ' style="display:none;"' : ''
  end

  def hide_unless(condition)
    hide_if(!condition)
  end

  def state_select(instance,method,options = {},html_options = {})
    select(instance,method,state_options(options.delete(:country)).sort,options,html_options)
  end

  def state_select_tag(name,value,options = {})
    select_tag(name,options_for_select(state_options(options.delete(:country)).sort.unshift(options.delete(:include_blank) ? '' : nil).compact,value),options)
  end

  private
  def state_options(country = nil)
    case country
    when 'Australia'
      ['Australian Capital Territory','New South Wales','Northern Territory','Queensland','South Australia','Tasmania','Victoria','Western Australia']
    when 'Canada'
      ['Alberta','British Columbia','Manitoba','New Brunswick','Newfoundland','Northwest Territories','Nova Scotia','Nunavut','Ontario','Prince Edward Island','Quebec','Saskatchewan','Yukon']
    when 'France'
      ['Alsace','Aquitaine','Auvergne','Bourgogne','Bretagne','Centre','Champagne-Ardenne','Corse','Franche-Comte','Ile-de-France','Languedoc-Roussillon','Limousin','Lorraine','Midi-Pyrenees','Nord-Pas-de-Calais','Basse-Normandie','Haute-Normandie','Pays de la Loire','Picardie','Poitou-Charentes',"Provence-Alpes-Cote d'Azur",'Rhone-Alpes']
    when 'Germany'
      ['Baden-Wurttemberg','Bayern','Berlin','Brandenburg','Bremen','Hamburg','Hessen','Mecklenburg- Vorpommern','Niedersachsen','Nordrhein-Westfalen','Rhineland- Pflaz','Saarland','Sachsen','Sachsen-Anhalt','Schleswig- Holstein','Thuringen']
    when 'India'
      ['Andhra Pradesh',  'Arunachal Pradesh',  'Assam','Bihar','Chhattisgarh','New Delhi','Goa','Gujarat','Haryana','Himachal Pradesh','Jammu and Kashmir','Jharkhand','Karnataka','Kerala','Madhya Pradesh','Maharashtra','Manipur','Meghalaya','Mizoram','Nagaland','Orissa','Punjab','Rajasthan','Sikkim','Tamil Nadu','Tripura','Uttaranchal','Uttar Pradesh','West Bengal']
    when 'Japan'
      ['Hokkaido','Aomori','Iwate','Miyagi','Akita','Yamagata','Fukushima','Ibaraki','Tochigi','Gunma','Saitama','Chiba','Tokyo','Kanagawa','Niigata','Toyama','Ishikawa','Fukui','Yamanashi','Nagano','Gifu','Shizuoka','Aichi','Mie','Shiga','Kyoto','Osaka','Hyogo','Nara','Wakayama','Tottori','Shimane','Okayama','Hiroshima','Yamaguchi','Tokushima','Kagawa','Ehime','Kochi','Fukuoka','Saga','Nagasaki','Kumamoto','Oita','Miyazaki','Kagoshima','Okinawa']
    when 'South Africa'
      ['Western Cape','Northern Cape','Free State','Gauteng','Eastern Cape','KwaZulu-Natal','Limpopo','Mpumalanga','North West']
    when 'Spain'
      ['Alava','Albacete','Alicante','Almeria','Asturias','Avila','Badajoz','Barcelona','Burgos','Caceres','Cadiz','Cantrabria','Castellon','Ceuta','Ciudad Real','Cordoba','Cuenca','Girona','Granada','Guadalajara','Guipuzcoa','Huelva','Huesca','Islas Baleares','Jaen','La Coruna','Leon','Lleida','Lugo','Madrid','Malaga','Melilla','Murcia','Navarra','Ourense','Palencia','Palmas, Las','Pontevedra','Rioja, La','Salamanda',  'Santa Cruz de Tenerife','Segovia','Sevila','Soria','Tarragona','Teruel','Toledo','Valencia','Valladolid','Vizcaya','Zamora','Zaragoza']
    when 'Uganda'
      ['Abim','Adjumani','Amolatar','Amuria','Apac','Arua','Budaka','Bugiri','Bukwa','Bulisa','Bundibugyo','Bushenyi','Busia','Busiki','Butaleja','Dokolo','Gulu','Hoima','Ibanda','Iganga','Jinja','Kaabong','Kabale','Kabarole','Kaberamaido','Kabingo','Kalangala','Kaliro','Kampala','Kamuli','Kamwenge','Kanungu','Kapchorwa','Kasese','Katakwi','Kayunga','Kibale','Kiboga','Kilak','Kiruhura','Kisoro','Kitgum','Koboko','Kotido','Kumi','Kyenjojo','Lira','Luwero','Manafwa','Maracha','Masaka','Masindi','Mayuge','Mbale','Mbarara','Mityana','Moroto','Moyo','Mpigi','Mubende','Mukono','Nakapiripirit','Nakaseke','Nakasongola','Nebbi','Ntungamo','Oyam','Pader','Pallisa','Rakai','Rukungiri','Sembabule','Sironko','Soroti','Tororo','Wakiso','Yumbe']
    when 'United Kingdom'
      ['Aberdeenshire','Angus','Argyll','Ayrshire','Banffshire','Caithness','Clackmannanshire','Dumfriesshire','Dunbartonshire','East Lothian','Fife','Inverness-Shire','Kincardineshire','Kinross-Shire','Kirkcudbrightshire','Lanarkshire','Midlothian','Morayshire','Nairnshire','Peeblesshire','Perthshire','Renfrewshire','Ross-Shire','Roxburghshire','Selkirkshire','Stirlingshire','Sutherland','West Lothian','Wigtownshire'] +
      ['Clwyd','Dyfed','Gwent','Gwynedd','Mid Glamorgan','Powys','South Glamorgan','West Glamorgan'] + 
      ['Avon','Bedfordshire','Berkshire','Berwickshire','Buckinghamshire','Cambridgeshire','Cheshire','Cleveland','Cornwall','County Durham','Cumbria','Derbyshire','Devon','Dorset','East Sussex','Essex','Gloucestershire','Hampshire','Herefordshire','Hertfordshire','Kent','Lancashire','Leicestershire','Lincolnshire','London','Merseyside','Middlesex','Norfolk','North Humberside','North Yorkshire','Northamptonshire','Northumberland','Nottinghamshire','Oxfordshire','Salop','Shropshire','Somerset','South Humberside','South Yorkshire','Staffordshire','Suffolk','Surrey','Tyne And Wear','Warwickshire','West Midlands','West Sussex','West Yorkshire','Wiltshire','Worcestershire'] +
      ['County Antrim','County Armagh','County Down','County Fermanagh','County Londonderry','County Tyrone'] +
      ['Channel Isles','Isle Of Arran','Isle Of Barra','Isle Of Benbecula','Isle Of Bute','Isle Of Canna','Isle Of Coll','Isle Of Colonsay','Isle Of Cumbrae','Isle Of Eigg','Isle Of Gigha','Isle Of Harris','Isle Of Iona','Isle Of Islay','Isle Of Jura','Isle Of Lewis','Isle Of Man','Isle Of Mull','Isle Of North Uist','Isle Of Rum','Isle Of Scalpay','Isle Of Skye','Isle Of South Uist','Isle Of Tiree','Isle Of Wight','Isles Of Scilly','Orkney','Shetland','Shetland Islands','Western Isles']
    when 'United States'
      ['Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','Washington D.C.','West Virginia','Wisconsin','Wyoming'].zip(state_options)
    else
      ['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','DC','WV','WI','WY']
    end
  end
end