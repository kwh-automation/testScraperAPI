require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_selecting_procedure_step_shows_operation_substeps
    test_selecting_operation_step_shows_phase_substeps
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1",false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save

    @mc.structure_builder.procedure_level.add_unit set_name: "Root Procedure"

    1.upto(5) do |i|
      @mc.structure_builder.operation_level.add_unit set_name: "Operation: " + i.to_s
    end

    @mc.structure_builder.operation_level.select_unit 1

    1.upto(5) do |i|
      @mc.structure_builder.phase_level.add_unit set_name: "Phase: " + i.to_s
    end

    @mc.structure_builder.procedure_level.select_unit 1
  end

  def test_selecting_procedure_step_shows_operation_substeps
    @mc.structure_builder.procedure_level.select_unit 1
    assert @mc.structure_builder.operation_level.operation_text(1).include?("Operation: 1")
    assert @mc.structure_builder.operation_level.operation_text(2).include?("Operation: 2")
    assert @mc.structure_builder.operation_level.operation_text(3).include?("Operation: 3")
    assert @mc.structure_builder.operation_level.operation_text(4).include?("Operation: 4")
    assert @mc.structure_builder.operation_level.operation_text(5).include?("Operation: 5")
  end

  def test_selecting_operation_step_shows_phase_substeps
    @mc.structure_builder.operation_level.select_unit 1
    assert @mc.structure_builder.phase_level.phase_text(1).include?("Phase: 1")
    assert @mc.structure_builder.phase_level.phase_text(2).include?("Phase: 2")
    assert @mc.structure_builder.phase_level.phase_text(3).include?("Phase: 3")
    assert @mc.structure_builder.phase_level.phase_text(4).include?("Phase: 4")
    assert @mc.structure_builder.phase_level.phase_text(5).include?("Phase: 5")
  end
end