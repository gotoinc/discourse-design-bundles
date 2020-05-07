# frozen_string_literal: true

module ShopAdvertisementSerializerMixin
  def self.included(klass)
    klass.attributes :shop_advertisement_html
  end

  def shop_advertisement_html
    shop_id = Discourse.cache.read(:store_ids_for_advertisement)&.sample
    current_user = object&.guardian&.user&.id

    best_answer_id = object.topic.custom_fields["accepted_answer_post_id"]&.to_i

    if best_answer_id.nil?
      # case for topic owner
      target_user_id = user_id
    else
      # case for best answer
      post = object.posts.select { |post| post[:id] == best_answer_id }

      target_user_id = post.first[:user_id].to_i
    end

    custom_field = UserCustomField.select(:value).where(user_id: target_user_id, name: 'storeId').last

    shop_id = custom_field unless custom_field.nil?

    DesignBundles.product_display_html(shop_id, current_user)
  end
end
