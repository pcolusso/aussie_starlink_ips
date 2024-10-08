require 'csv'
require 'netaddr'

module AussieStarlinkIPs

  # Fetch and parse a list directly from the Starlink feed.
  def self.fetch_list
    url = URI("https://geoip.starlinkisp.net/feed.csv")
    response = Net::HTTP.get_response(url)
    
    if response.is_a?(Net::HTTPSuccess)
      parse_csv(response.body)
    else
      raise "Failed to fetch data: #{response.code} #{response.message}"
    end
  end

  # Parse a provided CSV
  def self.parse_csv(file)
    list = []
    CSV.parse(file, headers: false) do |row|
      # RFC 8805 specifies the first two columns are the IP address in CIDR notation, and the country code.
      cidr = row[0]
      country_code = row[1]

      if country_code == "AU"
        if cidr.include?(":")
          list << NetAddr::IPv6Net.parse(cidr)
        else
          list << NetAddr::IPv4Net.parse(cidr)
        end
      end
    end

    list
  end

  def self.is_aussie?(ip_list, ip)
    ip_type = ip_include?(":") ? :v6 : :v4
    ip = ip_type == :v6 ? IPv6.parse(ip) : IPv4.parse(ip)

    # Both IPv4Net & IPv6Net have #contains.
    ip_list.each do |range|
      range_type = 
      if range.contains(ip)
        return true
      end
    end

    false
  end
end
