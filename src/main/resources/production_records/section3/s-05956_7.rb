require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_that_deleting_a_step_requires_confirmation
    test_steps_can_be_deleted
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "5"
    @mc.structure_builder.operation_level.add_unit set_name: "5"
    @mc.structure_builder.phase_level.add_unit set_name: "5"
  end

  def test_that_deleting_a_step_requires_confirmation
    @mc.structure_builder.phase_level.delete "1", confirm_delete: false
    @mc.wait_for_video
    @mc.structure_builder.phase_level.cancel
    assert @mc.structure_builder.phase_level.does_unit_exist? 1
  end

  def test_steps_can_be_deleted
    @mc.structure_builder.phase_level.delete "1"
    assert !@mc.structure_builder.phase_level.does_unit_exist?(1)
  end

end
