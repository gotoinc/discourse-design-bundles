# frozen_string_literal: true

module DesignBundles
  DESIGN_BUNDLES_URL = 'https://designbundles.net'

  def self.product_display_html(store_id, user_id)
    URI.parse("#{DESIGN_BUNDLES_URL}/product-display.php?store=#{store_id}&user=#{user_id}").read
  end
end
