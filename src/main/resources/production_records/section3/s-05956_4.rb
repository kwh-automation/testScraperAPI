require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_that_steps_are_not_automatically_added_to_the_structure
    test_procedure_steps_can_be_added
    test_procedure_steps_can_be_edited
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
  end

  def test_that_steps_are_not_automatically_added_to_the_structure
    assert !@mc.structure_builder.procedure_level.does_unit_exist?("1")
  end

  def test_procedure_steps_can_be_added
    @mc.structure_builder.procedure_level.add_unit set_name: "5"
  end

  def test_procedure_steps_can_be_edited
    @mc.structure_builder.procedure_level.settings "1"
    @mc.structure_builder.procedure_level.name = "6"
    @mc.structure_builder.procedure_level.save
  end

end
