# frozen_string_literal: true

require 'openssl'
require 'net/http'

module DesignBundles
  def self.product_display_html(store_id, user_id)
    store_hash = OpenSSL::HMAC.hexdigest('sha1', SiteSetting.DiscourseDesignBundles_hash_key, "#{store_id}")

    uri = URI.parse("#{SiteSetting.DiscourseDesignBundles_api_url}?store=#{store_hash}&user=#{user_id}")

    code = Net::HTTP.get_response(uri).code.to_s[0]

    uri.read unless code == 4 && code == 5
  end
end
