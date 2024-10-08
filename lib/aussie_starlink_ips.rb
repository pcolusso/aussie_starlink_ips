require 'csv'
require 'netaddr'

module AussieStarlinkIPs
  class IpList
    attr_reader :v4, :v6, :time_created

    def initialize(v4:, v6:)
      @v4 = v4
      @v6 = v6
      @time_created = Time.now
    end

    ##
    # Loads an IpList directly from Starlink.
    # This is not automatically called, so for internal purposes, it's key to ensure
    # that it is up to date.
    def self.from_starlink
      url = URI("https://geoip.starlinkisp.net/feed.csv")
      response = Net::HTTP.get_response(url)

      if response.is_a?(Net::HTTPSuccess)
        return IpList::from_csv(response.body)
      else
        raise "Failed to fetch data: #{response.code} #{response.message}"
      end
    end

    ##
    # Creates an IP List from a pre-provided CSV. Used mainly in testing harnesses.
    def self.from_csv(file)
      v4 = []
      v6 = []
      CSV.parse(file, headers: false) do |row|
        # RFC 8805 specifies the first two columns are the IP address in CIDR notation, and the country code.
        cidr = row[0]
        country_code = row[1]

        if country_code == "AU"
          if cidr.include?(":")
            v6 << NetAddr::IPv6Net.parse(cidr)
          else
            v4 << NetAddr::IPv4Net.parse(cidr)
          end
        end
      end

      IpList.new(v4: v4, v6: v6)
    end

    ##
    # Checks if a specified IP is inside australia, using the country code.
    def is_aussie?(ip)
      ip_type = ip.include?(":") ? :v6 : :v4
      ip = ip_type == :v6 ? NetAddr::IPv6.parse(ip) : NetAddr::IPv4.parse(ip)
      list = ip_type == :v6 ? @v6 : @v4

      list.each do |range|
        return true if range.contains(ip)
      end

      false
    end
  end

end
