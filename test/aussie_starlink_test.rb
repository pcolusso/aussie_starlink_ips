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

    result = AussieStarlinkIPs::IpList.from_starlink
    assert_equal 1, result.v4.length
    assert_equal 1, result.v6.length
    assert_instance_of NetAddr::IPv4Net, result.v4[0]
    assert_instance_of NetAddr::IPv6Net, result.v6[0]
  end

  def test_parse_csv
    result = AussieStarlinkIPs::IpList.from_csv(@sample_csv)
    assert_equal 1, result.v4.length
    assert_equal 1, result.v6.length
    assert_instance_of NetAddr::IPv4Net, result.v4[0]
    assert_instance_of NetAddr::IPv6Net, result.v6[0]
  end

  def test_is_aussie
    result = AussieStarlinkIPs::IpList.from_csv(@sample_csv)
    
    assert result.is_aussie?("192.168.0.1")
    assert result.is_aussie?("2001:db8::1")
    refute result.is_aussie?("10.0.0.1")
    refute result.is_aussie?("8.8.8.8")
  end

  def test_fetch_list_failure
    stub_request(:get, "https://geoip.starlinkisp.net/feed.csv")
      .to_return(status: 404)

    assert_raises(RuntimeError) { AussieStarlinkIPs::IpList.from_starlink }
  end
end
