module ShopAdvertisementSerializerMixin
  def self.included(klass)
    klass.attributes :shop_advertisement_html
  end
  def shop_advertisement_html
    shop_id = Discourse.cache.read(:store_ids_for_advertisement).sample
    user_id = object&.guardian&.user&.id
    DesignBundles.product_display_html(shop_id, user_id)
  end
end