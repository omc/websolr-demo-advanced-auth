require 'openssl'

unless ENV['WEBSOLR_URL']
  $stderr.puts "No WEBSOLR_URL defined in the environment! (config/initializers/solr.rb)"
  exit 1
end

unless ENV['WEBSOLR_AUTH']
  $stderr.puts "No WEBSOLR_AUTH defined in the environment! (config/initializers/solr.rb)"
  exit 1
end

$rsolr = RSolr.connect :url => ENV['WEBSOLR_URL']

module Websolr

  # Return correct authorization headers based on the given secret
  #
  # Authorization secret must be provided in the WEBSOLR_AUTH environment
  # variable or as a parameter to Websorl.auth_headers

  def self.auth_headers(secret=ENV['WEBSOLR_AUTH'])
    if secret
      time  = Time.now.to_i
      nonce = Time.now.to_i.to_s.split(//).sort_by{rand}.join
      auth  = OpenSSL::HMAC.hexdigest('sha1', secret, "#{time}#{nonce}")
      {
        'X-Websolr-Time'  => time,
        'X-Websolr-Nonce' => nonce,
        'X-Websolr-Auth'  => auth
      }
    else
      $stderr.puts "Websolr.auth_headers must be called with a secret token parameter, " +
        "or a value present in the WEBSOLR_AUTH environment variable."
      {}
    end
  end

end

