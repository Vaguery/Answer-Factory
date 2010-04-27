require 'rubygems'
require 'sinatra'

set :haml, { :format => :html5 } 

get '/' do
  haml :index
  # make couchdb request for since the beginning
  # render page with graph container of those points
end

# post /?last_id=123445
post '/' do
  <<-END
    <svg:circle cx="#{rand(500)}" cy="#{rand(500)}" r="#{rand(30)+30}" opacity=".02" stroke="none" stroke-width="0" fill="#{rand()<0.5 ? 'red' : 'white'}"/>
  END
  # make a couchdb request for guys since 123445
  # convert to svg data
end