# frozen_string_literal: true

module DesignBundles
  def self.product_display_html(store_id, user_id)
    URI.parse("#{SiteSetting.DiscourseDesignBundles_api_url}?store=#{store_id}&user=#{user_id}").read
  end
end
