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
UCF_MAP = { 'High School Student' => 'high_school',
            'Undergraduate Student' => 'undergrad',
            'Graduate Student (Masters)' => 'masters',
            'Graduate Student (PhD)' => 'phd',
            'Junior Professional' => 'junior_professionals',
            'STEM Professional (academia)' => 'stem_academia',
            'STEM Professional (industry)' => 'stem_industry',
            'Counselor/ Tutor' => 'counselors_tutors',
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
      puts "\n#{'='*50}\n"
      puts "add_to_group_for_stem_level"
      ucf = UserField.find_by(name: UCF_PRETTY_NAME)
      puts "UCF_ID: #{ucf.id} for #{UCF_PRETTY_NAME}"
      ucf_name = "user_field_#{ucf.id}"
      puts "UCF NAME: #{ucf_name}"
      stem_level=user.custom_fields[ucf_name]
      puts "Stem: #{stem_level}"
      stem_group = nil
      if stem_level
        stem_group = UCF_MAP[stem_level]
        puts "FOUND GROUP: #{stem_group}"
        if stem_group
          group = Group.find_by(name: stem_group)
          puts "group: #{group.id}"
          if group
            puts "add_to_group_for_stem_level: gid: #{group.id}. User: #{user.id}"
            gu = GroupUser.find_by(group_id: group.id, user_id: user.id)
            puts "ADDING TO #{stem_group}"
            GroupUser.create(group_id: group.id, user_id: user.id) unless gu
          end
        end
      end
      # remove from all other STEM Groups
      UCF_MAP.values.each do |group_name|
        puts "DELETE Looking for group name #{group_name} --should not be #{stem_group}"
        next if group_name == stem_group
        group = Group.find_by(name: group_name)
        next unless group
        puts "DELETE Looking for #{group.id} record"
        gu = GroupUser.find_by(group_id: group.id, user_id: user.id)
        puts "Destroying from #{group_name}!! " if gu
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
      puts "\n#{'='*50}\n"
      puts "CUSTOM Happening"
      user = User.find(self.user_id)
      GroupAssign.add_to_group_for_stem_level(user)
  end

  self.add_model_callback(User, :after_commit, on: :update) do
      puts "\n#{'='*50}\n"
      puts "USER Happening"
      user = User.find(self.id)
      GroupAssign.add_to_group_for_stem_level(user)
  end

end
