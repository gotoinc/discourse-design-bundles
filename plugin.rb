# name: design-bundles-community
# about: Discourse plugin to implement all extensions needed for Design Bundles company
# version: 0.0.1
# authors: Gotoinc (gotoinc.co)

add_to_serializer(:post, :external_user_id, false) do
  object&.user&.single_sign_on_record&.external_id
end
