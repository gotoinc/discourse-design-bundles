# frozen_string_literal: true

# name: DiscourseDesignBundles
# about: Discourse plugin to implement all extensions needed for Design Bundles company
# version: 0.1
# authors: Gotoinc
# url: https://github.com/gotoinc/discourse-design-bundles/

PLUGIN_NAME ||= 'DiscourseDesignBundles'

after_initialize do
  add_to_serializer(:post, :external_user_id, false) do
    object&.user&.single_sign_on_record&.external_id
  end
end
