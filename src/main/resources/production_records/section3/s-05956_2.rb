require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @checkboxes = ["header_image"]
    @file = resource("jpg_image")
    @file_name = File.basename(@file)
    @lot_number = uniq("")
    @product_id = uniq("1", false)
    @mbr_name = uniq("image_header_mt")

    pre_test
    test_image_can_be_uploaded_for_production_record_header
    test_user_uploaded_image_persists
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    assert !@mc.structure_builder.edit_mbr.header_settings.accountability_header_header_image_checkbox
  end

  def test_image_can_be_uploaded_for_production_record_header
    @mc.structure_builder.edit_mbr.header_settings.enable_accountability_header_header_image
    @mc.structure_builder.edit_mbr.header_settings.upload_new_logo = @file
    @mc.structure_builder.edit_mbr.header_settings.accept
    assert @mc.structure_builder.edit_mbr.header_settings.selected_image? @file_name
    @mc.structure_builder.edit_mbr._next
    @mc.success.displayed
  end

  def test_user_uploaded_image_persists
    @mc.structure_builder.edit_mbr_settings
    @mc.structure_builder.edit_mbr._next
    @mc.structure_builder.edit_mbr._next
    assert @mc.structure_builder.edit_mbr.header_settings.selected_image? @file_name
  end

end
