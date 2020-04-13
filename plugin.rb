# frozen_string_literal: true

# name: discourse-group-assign-by-custom-field
# about: Assign group per custom user field
# version: 0.1
# authors: pfaffman
# url: https://www.literatecomputing.com/

#register_asset "stylesheets/common/group-domain.scss"

enabled_site_setting :discourse_group_assign_by_custom_field_enabled

PLUGIN_NAME = 'DiscourseGroupAssignByCustomField'
UCF_PRETTY_NAME = 'STEM Level'
UCF_MAP = { 'High School Student' => 'high-schoolers',
            'Undergraduate Student' => 'undergrads',
            'Graduate Student (Masters)' => 'masters',
            'Graduate Student (PhD)' => 'phds',
            'Junior Professional' => 'junior_professionals',
            'STEM Professional (academia)' => 'stem_academia',
            'STEM Professional (industry)' => 'stem_professionals',
            'Counselor/ Tutor' => 'counselors-tutors'
          }

load File.expand_path('lib/discourse-group-assign-by-custom-field/engine.rb', __dir__)

after_initialize do
  # https://github.com/discourse/discourse/blob/master/lib/plugin/instance.rb

  # load File.expand_path('app/jobs/group_domain_daily.rb', __dir__)

  module ::GroupAssign
    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace GroupAssign
    end

    def self.add_to_group_for_stem_level(user)
      # should be called "set_group_for_stem_level"
      ucf = UserField.find_by(name: UCF_PRETTY_NAME)
      return unless ucf
      ucf_name = "user_field_#{ucf.id}"
      stem_level=user.custom_fields[ucf_name]
      stem_group = nil
      if stem_level
        stem_group = UCF_MAP[stem_level]
        if stem_group
          group = Group.find_by(name: stem_group)
          if group
            gu = GroupUser.find_by(group_id: group.id, user_id: user.id)
            GroupUser.create(group_id: group.id, user_id: user.id) unless gu
          end
        end
      end
      # remove from all other STEM Groups
      UCF_MAP.values.each do |group_name|
        next if group_name == stem_group
        group = Group.find_by(name: group_name)
        next unless group
        gu = GroupUser.find_by(group_id: group.id, user_id: user.id)
        gu.destroy if gu
      end
    end

    def self.remove_from_other_groups(user)
    end

  end

  require_dependency "application_controller"
  class GroupAssign::ActionsController < ::ApplicationController
    requires_plugin PLUGIN_NAME

    before_action :ensure_logged_in

    def list
      render json: success_json
    end
  end

  GroupAssign::Engine.routes.draw do
    get "/list" => "actions#list"
  end

  Discourse::Application.routes.append do
    mount ::GroupAssign::Engine, at: "/group-domain"
  end

  DiscourseEvent.on(:user_created) do |user|
    GroupAssign.add_to_group_for_stem_level(user)
  end

  self.add_model_callback(UserCustomField, :after_commit, on: :update) do
      user = User.find(self.user_id)
      GroupAssign.add_to_group_for_stem_level(user)
  end

  self.add_model_callback(User, :after_commit, on: :update) do
      user = User.find(self.id)
      GroupAssign.add_to_group_for_stem_level(user)
  end

end
