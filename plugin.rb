# frozen_string_literal: true

# name: DiscourseDesignBundles
# about: Discourse plugin to implement all extensions needed for Design Bundles company
# version: 0.2
# authors: Gotoinc
# url: https://github.com/gotoinc/discourse-design-bundles/

PLUGIN_NAME ||= 'DiscourseDesignBundles'

load File.expand_path('../lib/design_bundles.rb', __FILE__)

after_initialize do
  add_to_serializer(:post, :external_user_id, false) do
    object&.user&.single_sign_on_record&.external_id
  end

  class ::Jobs::CacheStoreIdsForAdvertisement < ::Jobs::Scheduled
    every 10.minutes

    def execute(args)
      store_ids = Post.joins("INNER JOIN user_custom_fields
                  ON user_custom_fields.user_id = posts.user_id")
          .where("posts.created_at > ?
                  AND user_custom_fields.name = 'storeId'
                  AND user_custom_fields.user_id > 0
                  AND user_custom_fields.value IS NOT NULL", 1.week.ago)
          .pluck('user_custom_fields.value').uniq
      Discourse.cache.write(:store_ids_for_advertisement, store_ids)
    end

  end

  TopicViewSerializer.class_eval do
    attributes :shop_advertisement_html

    def shop_advertisement_html
      shop_id = Discourse.cache.read(:store_ids_for_advertisement).sample
      user_id = object&.guardian&.user&.id
      DesignBundles.product_display_html(shop_id, user_id)
    end
  end

end
