require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @checkboxes = ["header_image"]

    pre_test
    test_structure_builder_properties_can_be_edited
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1", false), default_lot_amount: 5
    @mc.structure_builder.edit_mbr.select_release_role
    assert !@mc.structure_builder.edit_mbr.header_settings.accountability_header_header_image_checkbox
    @mc.structure_builder.edit_mbr.header_settings.save
  end

  def test_structure_builder_properties_can_be_edited
    @mc.structure_builder.edit_mbr.name = uniq("bye")
    @mc.structure_builder.edit_mbr.product_id = uniq("2",false)
    @mc.structure_builder.edit_mbr._next
    @mc.structure_builder.edit_mbr._next
    @mc.structure_builder.edit_mbr._next
    sleep 2
    assert @mc.success.displayed?
  end

end