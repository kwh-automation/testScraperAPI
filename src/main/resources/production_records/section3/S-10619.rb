require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("accountability_opt")
    @product_id = uniq("accountability_opt", false)
    @lot_number = uniq("lot_", true)
    @text = 'Testing'

    pre_test
    test_user_can_choose_to_display_options_on_accountability_page
    test_options_from_settings_show_on_accountability_page
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
  end

  def test_user_can_choose_to_display_options_on_accountability_page
    @mc.structure_builder.edit_mbr.header_settings.check_all_accountability_options @text
    assert @mc.header_settings.custom_text_checkbox
    assert @mc.header_settings.documents_checkbox
    assert @mc.header_settings.signatures_checkbox
    assert @mc.header_settings.forms_checkbox
    @mc.structure_builder.edit_mbr.header_settings.save
    assert @mc.success.displayed
    finish_mbr
  end

  def test_options_from_settings_show_on_accountability_page
    assert @mc.accountability.custom_text_element.visible?
    assert @mc.accountability.signatures_element.visible?
    assert @mc.accountability.documents_element.visible?
    assert @mc.accountability.forms_element.visible?
  end

  private
  def finish_mbr
    @mc.structure_builder.procedure_level.add_unit set_name: "Unit Procedure 1"
    @mc.structure_builder.operation_level.add_unit set_name: "Operation 1"
    @mc.structure_builder.phase_level.add_unit set_name: "Phase 1"
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number
    @mc.ebr_navigation.go_to_first "operation", @lot_number
  end
end