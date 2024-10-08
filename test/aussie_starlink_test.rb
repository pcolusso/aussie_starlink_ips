require_relative "test_helper"

require 'netaddr'

class AussieStarlinkIPsTest < Minitest::Test
  def setup
    @sample_csv = <<~CSV
      192.168.0.0/24,AU
      2001:db8::/32,AU
      10.0.0.0/8,US
    CSV
  end

  def test_fetch_list
    stub_request(:get, "https://geoip.starlinkisp.net/feed.csv")
      .to_return(status: 200, body: @sample_csv)

    result = AussieStarlinkIPs.fetch_list
    assert_equal 2, result.size
    assert_instance_of NetAddr::IPv4Net, result[0]
    assert_instance_of NetAddr::IPv6Net, result[1]
  end

  def test_parse_csv
    result = AussieStarlinkIPs.parse_csv(@sample_csv)
    assert_equal 2, result.size
    assert_instance_of NetAddr::IPv4Net, result[0]
    assert_instance_of NetAddr::IPv6Net, result[1]
  end

  def test_is_aussie
    ip_list = AussieStarlinkIPs.parse_csv(@sample_csv)
    
    assert AussieStarlinkIPs.is_aussie?(ip_list, "192.168.0.1")
    assert AussieStarlinkIPs.is_aussie?(ip_list, "2001:db8::1")
    refute AussieStarlinkIPs.is_aussie?(ip_list, "10.0.0.1")
    refute AussieStarlinkIPs.is_aussie?(ip_list, "8.8.8.8")
  end

  def test_fetch_list_failure
    stub_request(:get, "https://geoip.starlinkisp.net/feed.csv")
      .to_return(status: 404)

    assert_raises(RuntimeError) { AussieStarlinkIPs.fetch_list }
  end
end
