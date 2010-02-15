require 'will_paginate'
require 'json'

Admin.models.push('Contact', 'Market', 'Quote')
Admin.models -= ['Advertisement', 'Article', 'Category', 'Email', 'Newsletter']
Admin.skip_actions.push('articles', 'contact_send', 'data_center', 'data_center_search', 'login', 'logout', 'news', 'newsletter_signup', 'lost_password', 'press', 'quote_send', 'unsubscribe')
Base.domain = 'http://www.colocationxchange.com'
Base.domain_short = 'colocationxchange.com'
CMS.hierarchical_menus = true
# CMS.advertisement_sizes['Main banner'] = {:height => 159, :width => 685}
Base.startup

GeoKit::default_units = :miles
GeoKit::default_formula = :sphere
GeoKit::Geocoders::timeout = 3
# GeoKit::Geocoders::yahoo = 'REPLACE_WITH_YOUR_YAHOO_KEY'
GeoKit::Geocoders::google = Configuration.google_maps_key
GeoKit::Geocoders::geocoder_us = false
GeoKit::Geocoders::geocoder_ca = false
GeoKit::Geocoders::provider_order = [:google,:us]

MARKETS = [
  # 'Birmingham, AL',
  # 'Mobile, AL',
  # 'Montgomery, AL',
  # 'Little Rock, AK',
  # 'El Segundo, CA',
  'San Francisco, CA',
  # 'Newark, CA',
  # 'Vernon, CA',
  # 'Oakland, CA',
  'Los Angeles, CA',
  'San Diego, CA',
  # 'Hawthorne, CA',
  # 'San Jose, CA',
  # 'Marina del Rey, CA',
  # 'Santa Clara, CA',
  # 'Rancho Corodova, CA',
  # 'Brea, CA',
  # 'Fremont, CA',
  # 'Irvine, CA',
  # 'Sunnyvale, CA',
  # 'Sacramento, CA',
  # 'Anaheim, CA',
  # 'Emeryville, CA',
  # 'Tustin, CA',
  # 'Milpitas, CA',
  # 'Agoura Hills, CA',
  # 'Modesto, CA',
  # 'Santa Barbara, CA',
  # 'Riverside, CA',
  # 'San Luis Obispo, CA',
  # 'Fresno, CA',
  # 'San Bernaedino, CA',
  # 'Novato, CA',
  # 'Burbank, CA',
  # 'Santa Ana, CA',
  # 'San Ramon, CA',
  # 'Cypress, CA',
  # 'Palo Alto, CA',
  # 'Walnut Creek, CA',
  # 'Goleta, CA',
  # 'Ontario, CA',
  # 'Orange County, CA',
  # 'Roseville, CA',
  # 'Westminister, CO',
  # 'Englewood, CO',
  'Denver, CO',
  # 'Colorado Springs, CO',
  # 'Highlands Ranch, CO',
  # 'Morrison, CO',
  # 'Aurora, CO',
  # 'Thornton, CO',
  # 'Shelton, CT',
  # 'Stamford, CT',
  # 'Hartford, CT',
  # 'New Haven, CT',
  # 'Wilmington, DE',
  'Washington, DC',
  # 'Newark, DE',
  # 'Fort Lauderdale, FL',
  'Miami, FL',
  # 'Orlando, FL',
  # 'Boca Raton, FL',
  'Jacksonville, FL',
  # 'Tampa, FL',
  # 'Daytona Beach, FL',
  # 'Melbourne, FL',
  # 'Tallahassee, FL',
  # 'Fort Myers, FL',
  # 'Eatonville, FL',
  'Atlanta, GA',
  # 'Duluth, GA',
  # 'Lithia Springs, GA',
  # 'Macon, GA',
  # 'Norcross, GA',
  # 'Suwanee, GA',
  # 'Alpharetta, GA',
  # 'Smyrna, GA',
  # 'Augusta, GA',
  # 'Honolulu, HI',
  # 'Boise, ID',
  # 'Peoria, IL',
  'Chicago, IL',
  # 'Mt. Prospect, IL',
  # 'Elk Grove Village, IL',
  # 'Arlington Heights, IL',
  # 'Broadview, IL',
  # 'Northbrook, IL',
  # 'Riverdale, IL',
  # 'Columbus, IN',
  'Indianapolis, IN',
  # 'South Bend, IN',
  # 'Evansville, IN',
  # 'Des Moines, IA',
  # 'Monticello, IA',
  # 'Overland Park, KS',
  # 'Lenexa, KS',
  # 'Shawnee Mission, KS',
  # 'Topeka, KS',
  # 'Kansas City, KS',
  # 'Wichita, KS',
  # 'Olive Hill, KY',
  # 'Louisville, KY',
  # 'Lexington, KY',
  'New Orleans, LA',
  # 'Metairie, LA',
  # 'Baton Rouge, LA',
  # 'Shreveport, LA',
  # 'Presque Isle, ME',
  # 'Biddeford, ME',
  # 'Portland, ME',
  # 'Somerville, MA',
  # 'Watertown, MA',
  # 'Marlborough, MA',
  # 'Rockland, MA',
  # 'Waltham, MA',
  'Boston, MA',
  # 'Medford, MA',
  # 'Springfield, MA',
  # 'Cambridge, MA',
  # 'Worcester, MA',
  # 'Andover, MA',
  # 'Charlestown, MA',
  # 'Sentinel-Bedford, MA',
  # 'Sentinel-Needham, MA',
  # 'Framingham, MA',
  # 'Troy, MI',
  # 'Southfield, MI',
  # 'South Bend, MI',
  'Detroit, MI',
  # 'Lansing, MI',
  # 'Dearborn, MI',
  # 'Farmington Hills, MI',
  # 'Grand Rapids, MI',
  # 'Minneapolis, MN',
  # 'St. Paul, MN',
  # 'Minnetonka, MN',
  # 'Cologne, MN',
  # 'Jackson, MS',
  'St. Louis, MO',
  'Kansas City, MO',
  # 'Columbia, MO',
  # 'Springfield, MO',
  # 'Maryland Heights, MO',
  # 'Aurora, NE',
  'Omaha, NE',
  # 'Reno, NV',
  # 'Las Vegas, NV',
  # 'Henderson, NV',
  # 'Manchester, NH',
  # 'Bedford, NH',
  # 'Portsmouth, NH',
  # 'Nashua, NH',
  # 'Secaucus, NJ',
  # 'Carlstadt, NJ',
  # 'Piscataway, NJ',
  # 'Newark, NJ',
  # 'Jersey City, NJ',
  # 'Weehaweken, NJ',
  # 'Brunswick, NJ',
  # 'North Bergen, NJ',
  # 'Clifton, NJ',
  # 'Trenton, NJ',
  # 'Albuquerque, NM',
  'New York, NY',
  # 'Wappingers Falls, NY',
  # 'Brooklyn, NY',
  # 'Syracuse, NY',
  # 'Rochester, NY',
  # 'Buffalo, NY',
  # 'Albany, NY',
  # 'Chappaqua, NY',
  # 'Woodbury, NY',
  # 'Garden City, NY',
  # 'Westbury, NY',
  # 'Commack, NY',
  # 'White Plains, NY',
  # 'Purchase, NY',
  # 'Staten Island, NY',
  # 'Gates, NY',
  # 'Manhattan, NY',
  # 'Colonie, NY',
  # 'Binghampton, NY',
  # 'Hicksville, NY',
  # 'Charlotte, NC',
  # 'Winston-Salem, NC',
  # 'Cary, NC',
  'Raleigh, NC',
  # 'Greensboro, NC',
  # 'Asheville, NC',
  # 'Greensboro, NC',
  # 'Durham, NC',
  # 'Columbus, OH',
  'Cleveland, OH',
  'Cincinnati, OH',
  # 'Garfield Heights, OH',
  # 'Akron, OH',
  # 'Dayton, OH',
  # 'Lewis center, OH',
  # 'Copley, OH',
  # 'Toledo, OH',
  # 'Hilliard, OH',
  # 'Waynesville, OH',
  # 'Oklahoma City, OK',
  # 'Tulsa, OK',
  # 'Eugene, OR',
  'Portland, OR',
  # 'Bandon, OR',
  # 'Cedar Hills, OR',
  # 'Tigard, OR',
  # 'Beaverton, OR',
  'Philadelphia, PA',
  'Pittsburgh, PA',
  # 'Norristown, PA',
  # 'Hatfield, PA',
  # 'Warminster, PA',
  # 'King of Prussia, PA',
  # 'Harrisburg, PA',
  # 'Smithfield, RI',
  'Providence, RI',
  # 'Spartanburg, SC',
  'Columbia, SC',
  # 'Chattanooga, TN',
  # 'Nashville, TN',
  'Memphis, TN',
  # 'Berry hill, TN',
  'Houston, TX',
  'Dallas, TX',
  # 'Austin, TX',
  # 'San Antonio, TX',
  # 'Carrollton, TX',
  # 'Waco, TX',
  # 'Lubbock, TX',
  # 'Fort Worth, TX',
  # 'Wichita Falls, TX',
  # 'Christi, TX',
  # 'El Paso, TX',
  # 'Stratford, TX',
  # 'Amarillo, TX',
  # 'Harlingen, TX',
  # 'Laredo, TX',
  # 'Santa Teresa, TX',
  # 'McAllen, TX',
  # 'Irving, TX',
  # 'Richardson, TX',
  # 'Las Colinas, TX',
  # 'Grand Prairie, TX',
  # 'Beaumont, TX',
  # 'Long View, TX',
  'Salt Lake City, UT',
  # 'Orem, UT',
  # 'St. George, UT',
  # 'Chantilly, VA',
  # 'Ashburn, VA',
  # 'Herndon, VA',
  # 'Vienna, VA',
  # 'Reston, VA',
  # 'Sterling, VA',
  # 'Bristow, VA',
  # 'McLean, VA',
  # 'Norfolk, VA',
  'Richmond, VA',
  # 'Culpepper, VA',
  # 'Fairfax, VA',
  'Seattle, WA',
  # 'Tukwila, WA',
  # 'Spokane, WA',
  # 'Lynnwood, WA',
  # 'Renton, WA',
  # 'Liberty Lake, WA',
  # 'Vancouver, WA',
  # 'Kirkland, WA',
  'Milwaukee, WI',
  # 'Madison, WI',
  # 'Brookfield, WI',
  # 'Cheyenne, WY'
].collect{|market|
  market = market.split(',')
  {:city => market.shift.strip, :state => market.pop.strip.upcase}
}.sort{|a, b| a[:city].downcase <=> b[:city].downcase}