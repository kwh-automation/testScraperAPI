require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @text = "Testing the custom text."
    @lot_number = uniq("lot_", true)
    @product_id = uniq("1", false)
    @mbr_name = uniq("custom_text_mt")

    pre_test
    test_custom_text_can_be_entered_in_builder
    test_custom_text_appears_in_accountability_page
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    assert !@mc.structure_builder.edit_mbr.header_settings.custom_text_checkbox
  end

  def test_custom_text_can_be_entered_in_builder
    @mc.structure_builder.edit_mbr.header_settings.enable_custom_text
    @mc.structure_builder.edit_mbr.header_settings.add_custom_text @text
    @mc.structure_builder.edit_mbr.header_settings.save
  end

  def test_custom_text_appears_in_accountability_page
    finish_mbr
    assert @mc.accountability.custom_text_element.visible?
    assert @mc.accountability.custom_text_element.attribute('innerText').include? @text
  end

    private
  def finish_mbr
    @mc.structure_builder.procedure_level.add_unit set_name: "Unit Procedure 1"
    @mc.structure_builder.operation_level.add_unit set_name: "Operation 1"
    @mc.structure_builder.phase_level.add_unit set_name: "Phase 1"
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number
    @mc.ebr_navigation.go_to_first "operation", @lot_number, custom_name:"Operation 1"
  end

end
