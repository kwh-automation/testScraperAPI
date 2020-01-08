require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @user = "S-07506"
    @lot_number = uniq("lot_", true)
    @admin = env['admin_user']
    @admin_pass = env["password"]
    @mbr_name = "Template_test"
    @mbr_name_2 = "Template_Use"
    @product_id = "Template_id"
    @product_id_2 = "Template_Use_id"
    @phase_temp = uniq("Phase_", false)
    @operation_temp = uniq("Operation_", false)
    @procedure_temp = uniq("Unit_Procedure_", false)
    @new_phase = uniq('New Phase', false)
    @new_operation = uniq('New Operation', false)
    @new_procedure = uniq('New Unit Procedure', false)

    pre_test
    test_template_can_save_per_level_without_duplicates
    test_saved_templates_can_be_viewed_and_edited
    test_user_can_use_templates_in_new_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    sleep 2
    @mc.success.displayed
    @mc.structure_builder.procedure_level.add_unit set_name: @procedure_temp
    @mc.structure_builder.operation_level.add_unit set_name: @operation_temp
    @mc.structure_builder.phase_level.add_unit set_name: @phase_temp
  end

  def test_template_can_save_per_level_without_duplicates
    @mc.structure_builder.phase_level.save_template
    @mc.template_name.submit
    assert @mc.success.displayed
    @mc.structure_builder.phase_level.save_template
    @mc.template_name.submit
    sleep 2
    assert @mc.template_name.template == "Phase_ (1)"
    @mc.template_name.cancel

    @mc.structure_builder.operation_level.save_template
    @mc.template_name.template = @operation_temp
    @mc.template_name.submit
    assert @mc.success.displayed
    @mc.structure_builder.operation_level.save_template
    @mc.template_name.template = @operation_temp
    @mc.template_name.submit
    sleep 2
    assert @mc.template_name.template == "Operation_ (1)"
    @mc.template_name.cancel

    @mc.structure_builder.procedure_level.save_template
    @mc.template_name.template = @procedure_temp
    @mc.template_name.submit
    assert @mc.success.displayed
    @mc.structure_builder.procedure_level.save_template
    @mc.template_name.template = @procedure_temp
    @mc.template_name.submit
    sleep 2
    assert @mc.template_name.template == "Unit_Procedure_ (1)"
    @mc.template_name.cancel
  end

  def test_saved_templates_can_be_viewed_and_edited
    @mc.structure_builder.options
    @mc.structure_builder.open_template_library

    @mc.template_library.procedure_library.search @procedure_temp
    @mc.template_library.procedure_library.edit_title @new_procedure
    assert @mc.success.displayed

    @mc.template_library.switch_tab 2
    @mc.template_library.operation_library.search @operation_temp
    @mc.template_library.operation_library.edit_title @new_operation
    assert @mc.success.displayed

    @mc.template_library.switch_tab 3
    @mc.template_library.phase_library.search @phase_temp
    @mc.template_library.phase_library.edit_title @new_phase
    assert @mc.success.displayed
    @mc.template_library.close_library
  end

  def test_user_can_use_templates_in_new_master_template
    @mc.structure_builder.back
    @mc.ebr.open_new_mbr_structure @mbr_name_2, @product_id_2
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    assert @mc.success.displayed
    @mc.template_library.procedure_library.import_template @new_procedure
    @mc.template_library.operation_library.import_template @new_operation
    @mc.template_library.phase_library.import_template @new_phase
  end

end
