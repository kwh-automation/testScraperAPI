require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_structure_properties_are_defined_when_new_structure_created
    test_master_template_dnh_is_required
    test_choosing_lot_number_configuration
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
  end

  def test_structure_properties_are_defined_when_new_structure_created
    @mc.ebr.create_master_batch_record
    assert @mc.structure_builder.edit_mbr.name_element.visible?
  end

  def test_master_template_dnh_is_required
    @mc.structure_builder.edit_mbr.name = ""
    @mc.structure_builder.edit_mbr.product_id = ""
    @mc.structure_builder.edit_mbr.header_settings.save
    assert @mc.structure_builder.edit_mbr.missing_required_mbr_info_warning_element.visible?
    @mc.structure_builder.edit_mbr.name = uniq("s-05956_1")
    @mc.structure_builder.edit_mbr.header_settings.save
    assert @mc.structure_builder.edit_mbr.missing_required_mbr_info_warning_element.visible?
    @mc.structure_builder.edit_mbr.product_id = uniq("product_id")
  end

  def test_choosing_lot_number_configuration
    @mc.structure_builder.edit_mbr.lot_number_configuration = "Manually Enter on Production Record"
    assert @mc.structure_builder.edit_mbr.lot_number_configuration_element.attribute("innerHTML").include?("Manually Enter on Production Record")
    @mc.structure_builder.edit_mbr._next
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
  end

end
