# frozen_string_literal: true

# name: DiscourseDesignBundles
# about: Discourse plugin to implement all extensions needed for Design Bundles company
# version: 0.6
# authors: Gotoinc
# url: https://github.com/gotoinc/discourse-design-bundles/

PLUGIN_NAME ||= 'DiscourseDesignBundles'

enabled_site_setting :DiscourseDesignBundles_enabled

load File.expand_path('lib/design_bundles.rb', __dir__)
load File.expand_path('app/serializers/shop_advertisement_serializer_mixin.rb', __dir__)

register_asset 'stylesheets/design_bundles_settings.scss'

after_initialize do
  add_to_serializer(:post, :external_user_id, false) do
    object&.user&.single_sign_on_record&.external_id
  end

  register_html_builder('server:before-head-close') do
    "<link rel='stylesheet' type='text/css' href='#{SiteSetting.DiscourseDesignBundles_css_url}'>"
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

      #FIXME HACK FOR TESTING
      # store_ids = [4079, 1630, 2972, 2077, 3253] if store_ids.empty?

      Discourse.cache.write(:store_ids_for_advertisement, store_ids)
    end
  end

  TopicViewSerializer.class_eval do
    include ShopAdvertisementSerializerMixin
  end
end
