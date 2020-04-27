module DesignBundles
  DesignBundlesURL = "https://designbundles.net"
  def self.product_display_html(store_id, user_id)
    URI.parse("#{DesignBundlesURL}/product-display.php?store=#{store_id}&user=#{user_id}").read
  end
end