require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_phase_can_be_configured_to_require_verification_and_unique_verifier
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("S05872_", false), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "1_Procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "1_Operation"
    @mc.structure_builder.phase_level.add_unit set_name: "1_Phase"
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
  end

  def test_phase_can_be_configured_to_require_verification_and_unique_verifier
    wait_until{@mc.phase_step.phase_complete_element.visible?}
    @mc.phase_step.phase_complete_element.click
    @mc.phase_step.enable_verification
    assert (@mc.phase_step.is_verification_enabled?)
    @mc.phase_step.enable_unique_verifier if @mc.phase_step.is_verification_enabled?
    assert (@mc.phase_step.is_unique_verifier_enabled?)
    @mc.phase_step.phase_complete_element.click
    assert (@mc.phase_step.is_verification_enabled?)
    assert (@mc.phase_step.is_unique_verifier_enabled?)
    @mc.wait_for_video
  end
end