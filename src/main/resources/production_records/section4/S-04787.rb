require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @role = "FT_ADMIN"

    pre_test
    test_phase_steps_can_be_configured_to_send_notification_to_roles_upon_completion
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("S04718_", false), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "1_Procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "1_Operation"
    @mc.structure_builder.phase_level.add_unit set_name: "1_Phase"
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text:"General Text Step 1"
  end

  def test_phase_steps_can_be_configured_to_send_notification_to_roles_upon_completion
    @mc.phase_step.general_text.enable_completion_notification
    assert @mc.phase_step.general_text.is_completion_notification_enabled?
    @mc.phase_step.notification_role_toolbar
    @mc.phase_step.general_text.choose_notification_role @role
    assert @mc.phase_step.general_text.is_completion_notification_enabled?
    chosen_roles_text = @mc.phase_step.notification_role_toolbar_text_element.text
    assert chosen_roles_text.include? @role
  end

end