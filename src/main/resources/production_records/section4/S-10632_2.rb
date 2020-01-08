require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @connection = MCAPI.new
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @admin_role = env['test_admin_role']
    @second_role = uniq("second_role_")

    pre_test
    test_user_can_assign_multiple_witness_roles_to_phase_step
    test_user_can_assign_multiple_verification_roles_to_phase_step
    test_user_can_assign_multiple_correction_verification_roles_to_phase_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.create_admin_role @second_role, @admin
    @mc.ebr.open_new_mbr_structure uniq("S10632_2_", false), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "1_Procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "1_Operation"
    @mc.structure_builder.phase_level.add_unit set_name: "1_Phase"
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
  end

  def test_user_can_assign_multiple_witness_roles_to_phase_step
    @mc.phase_step.add_general_text
    @mc.phase_step.enable_witness
    @mc.phase_step.general_text.authorized_roles_toolbar
    @mc.phase_step.general_text.choose_authorized_role @admin_role
    @mc.phase_step.general_text.choose_authorized_role @second_role
  end

  def test_user_can_assign_multiple_verification_roles_to_phase_step
    @mc.phase_step.add_numeric
    @mc.phase_step.enable_verification
    @mc.phase_step.numeric_data.authorized_roles_toolbar
    @mc.phase_step.numeric_data.choose_authorized_role @admin_role
    @mc.phase_step.numeric_data.choose_authorized_role @second_role
  end

  def test_user_can_assign_multiple_correction_verification_roles_to_phase_step
    @mc.phase_step.add_date_step
    @mc.phase_step.enable_correction_verification
    @mc.phase_step.date_step.authorized_roles_toolbar
    @mc.phase_step.date_step.choose_authorized_role @admin_role
    @mc.phase_step.date_step.choose_authorized_role @second_role
  end

end