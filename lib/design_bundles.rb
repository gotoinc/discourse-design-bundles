# frozen_string_literal: true

require 'digest/sha1'
require 'net/http'

module DesignBundles
  def self.product_display_html(store_id, user_id)
    return '' if SiteSetting.DiscourseDesignBundles_api_url.strip.empty?

    store_hash = Digest::SHA1.hexdigest(SiteSetting.DiscourseDesignBundles_hash_key + store_id.to_s)

    uri = URI.parse("#{SiteSetting.DiscourseDesignBundles_api_url}?store=#{store_hash}&user=#{user_id}")

    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      return response.body
    else
      return ''
    end
  end
end
