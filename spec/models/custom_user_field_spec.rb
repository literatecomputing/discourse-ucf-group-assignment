# frozen_string_literal: true

require 'rails_helper'

describe User do
  let(:user) { Fabricate(:user) }
  let!(:group1) { Fabricate(:group, name: "group-one") }
  let!(:group2) { Fabricate(:group, name: "group-two") }

  before do
    SiteSetting.user_custom_field_assigns_group_enabled = true
    SiteSetting.user_custom_field_map_name = "group_map_field"
    SiteSetting.user_custom_field_map = "one:group-one|two:group-two"
  end
  # TODO: set the custom field name setting

  # TODO create a user field map setting
  # todo enable plugin
  #  ucf = UserField.find_by(name: SiteSetting.user_custom_field_map_name)

  describe "custom fields assigns groups" do
    it "updates group  when custom field is changed" do
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).to eq(nil)
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).to eq(nil)

      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'one'
      user.save
      expect(user.custom_fields[SiteSetting.user_custom_field_map_name]).to eq('one')
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).not_to eq(nil)
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).to eq(nil)

      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'two'
      user.save
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).not_to eq(nil)
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).to eq(nil)
    end

    it 'does not fail if custom field is not set' do
      SiteSetting.user_custom_field_map_name = "not_a_field"
      user.custom_fields['something_else'] = 'banana'
      expect(user.save).to eq(true)
    end

    it 'works if group membership was set manually' do
      GroupUser.create(group_id: group1.id, user_id: user.id)
      GroupUser.create(group_id: group2.id, user_id: user.id)
      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'one'
      user.save
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).not_to eq(nil)
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).to eq(nil)
    end

    it 'does not fail if custom field is set non-existent group' do
      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'not_a_group'
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).to eq(nil)
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).to eq(nil)
    end

    it "updates group  when custom field is changed" do
      SiteSetting.user_custom_group_add_only = true
      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'one'
      user.save
      expect(user.custom_fields[SiteSetting.user_custom_field_map_name]).to eq('one')
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).not_to eq(nil)
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).to eq(nil)

      user.custom_fields[SiteSetting.user_custom_field_map_name] = 'two'
      user.save
      expect(GroupUser.find_by(group_id: group2.id, user_id: user.id)).not_to eq(nil)
      expect(GroupUser.find_by(group_id: group1.id, user_id: user.id)).not_to eq(nil)
    end
  end
end
