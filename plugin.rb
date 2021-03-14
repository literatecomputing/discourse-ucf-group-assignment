# frozen_string_literal: true

# name: user-custom-field-assigns-group
# about: Assign group according to custom user field value
# version: 0.1
# authors: pfaffman
# url: https://www.literatecomputing.com/

#register_asset "stylesheets/common/group-domain.scss"

enabled_site_setting :user_custom_field_assigns_group_enabled

after_initialize do
  add_to_class(:user, :sync_group_membership_to_ucf_map) do
    return unless SiteSetting.user_custom_field_map_name.present?
    ucf_value = self.custom_fields[SiteSetting.user_custom_field_map_name]

    ucf_map_array = SiteSetting.user_custom_field_map.split("|")
    ucf_map = {}
    ucf_map_array.each do |e|
      key_value = e.split(":")
      ucf_map[key_value[0]] = key_value[1]
    end
    mapped_group = nil
    if ucf_map.present?
      mapped_group = ucf_map[ucf_value]
      if mapped_group
        group = Group.find_by(name: mapped_group)
        if group
          gu = GroupUser.find_by(group_id: group.id, user_id: id)
          GroupUser.create(group_id: group.id, user_id: id) unless gu
        end
      end
    end
    # remove from other mapped groups
    unless SiteSetting.user_custom_group_add_only
      ucf_map.values.each do |group_name|
        next if group_name == mapped_group
        group = Group.find_by_name(group_name)
        next unless group
        gu = GroupUser.find_by(group_id: group.id, user_id: self.id)
        gu.destroy if gu
      end
    end
  end

  add_model_callback(User, :after_commit) do
    self.sync_group_membership_to_ucf_map
  end

end
