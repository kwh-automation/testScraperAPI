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
    test_image_displays_if_configured
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    assert !@mc.structure_builder.edit_mbr.header_settings.accountability_header_header_image_checkbox
    @mc.structure_builder.edit_mbr.header_settings.enable_accountability_header_header_image
    @mc.structure_builder.edit_mbr.header_settings.upload_new_logo = @file
    @mc.structure_builder.edit_mbr.header_settings.accept
    assert @mc.structure_builder.edit_mbr.header_settings.selected_image? @file_name
    @mc.structure_builder.edit_mbr._next
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    assert !@mc.structure_builder.edit_mbr.header_settings.accountability_header_header_image_checkbox
    @mc.structure_builder.edit_mbr._next
  end

   def test_image_displays_if_configured
    @mc.structure_builder.procedure_level.add_unit set_name: "Unit Procedure: 1"
    @mc.structure_builder.operation_level.add_unit set_name: "Operation: 1"
    @mc.structure_builder.phase_level.add_unit set_name: "Phase: 1"
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number
    @mc.ebr_navigation.go_to_first "Unit Procedure", @lot_number, custom_name:"Unit Procedure: 1"
  end

end
