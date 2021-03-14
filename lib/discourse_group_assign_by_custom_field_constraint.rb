class DiscourseGroupAssignByCustomFieldConstraint
  def matches?(request)
    SiteSetting.user_custom_field_assigns_group_enabled
  end
end
