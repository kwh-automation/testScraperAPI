require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_id = uniq("1", false)
    @mbr_name = uniq("custom_header_mt")

    pre_test
    test_user_can_add_6_custom_headers_with_or_without_content
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
  end

  def test_user_can_add_6_custom_headers_with_or_without_content
    @mc.structure_builder.edit_mbr.header_settings.add_max_custom_headers
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 1, "New Header 1", "New Content 1"
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 2, "New Header 2", "New Content 2"
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 3, "New Header 3", "New Content 3"
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 4, "New Header 4", ""
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 5, "New Header 5", ""
    @mc.structure_builder.edit_mbr.header_settings.add_label_and_content 6, "New Header 6", ""
    @mc.structure_builder.edit_mbr.header_settings.warning_displayed?
    @mc.structure_builder.edit_mbr.header_settings.save_settings

    assert @mc.success.displayed with_text: "Settings saved successfully"
  end

end