# frozen_string_literal: true

module ShopAdvertisementSerializerMixin
  def self.included(klass)
    klass.attributes :shop_advertisement_html
  end

  def shop_advertisement_html
    current_user = object&.guardian&.user&.id

    best_answer_id = object.topic.custom_fields["accepted_answer_post_id"]

    target_user_id = best_answer_id ? Post.find(best_answer_id).user_id : user_id

    shop_id = UserCustomField.where(user_id: target_user_id, name: 'storeId').first&.value ||
              Discourse.cache.read(:store_ids_for_advertisement)&.sample

    DesignBundles.product_display_html(shop_id, current_user)
  end
end
