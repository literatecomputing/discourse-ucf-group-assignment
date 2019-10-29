class DiscourseGroupAssignByCustomFieldConstraint
  def matches?(request)
    SiteSetting.discourse_group_assign_by_custom_field_enabled
  end
end
