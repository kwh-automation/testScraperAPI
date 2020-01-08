require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_phases_can_be_added_under_operations
    test_phase_properties_can_be_edited_after_creation
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
  end

  def test_phases_can_be_added_under_operations
    @mc.structure_builder.procedure_level.add_unit set_name: "unit_procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "operation"
    @mc.structure_builder.phase_level.add_unit set_name: "phase 1"
    @mc.structure_builder.phase_level.add_unit set_name: "phase 2"
    assert @mc.structure_builder.phase_level.does_unit_exist? 1
    assert @mc.structure_builder.phase_level.does_unit_exist? 2
  end

  def test_phase_properties_can_be_edited_after_creation
    @mc.structure_builder.phase_level.settings 1
    @mc.structure_builder.phase_level.name = "phase rename"
    @mc.structure_builder.phase_level.save
    assert @mc.structure_builder.phase_level.get_phase_name(1).include?("phase rename")
    assert !@mc.structure_builder.phase_level.get_phase_name(1).include?("phase 1")
  end

end
