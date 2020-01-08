require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @imported_mbr_name = uniq("Imported MT ")
    @imported_mbr_id = uniq("Imported ID ")

    pre_test
    test_importing_master_template_file
    test_editing_master_template_name_and_product_id_of_imported_master_template
    test_viewing_imported_master_template_on_list_page
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
  end

  def test_importing_master_template_file
    @mc.go_to.ebr.upload_master_batch_record
    @mc.wait_for_video
    @mc.mbr_upload_warning.continue
    @mc.master_template_upload.choose_file = resource("test_master_template")
    assert @mc.master_template_upload.close_status_message_element.visible?
    @mc.wait_for_video
    @mc.master_template_upload.close_status_message
  end

  def test_editing_master_template_name_and_product_id_of_imported_master_template
    @mc.master_template_upload.view_mbr
    @mc.structure_builder.edit_mbr_settings
    @mc.edit_mbr.name = @imported_mbr_name
    @mc.edit_mbr.product_id = @imported_mbr_id
    @mc.edit_mbr._select_tab "Header Configuration"
    @mc.header_settings.save_settings
  end

  def test_viewing_imported_master_template_on_list_page
    @mc.structure_builder.back
    @mc.master_batch_record_list.filter_by(:product_name, @imported_mbr_name)
    assert @mc.master_batch_record_list.master_batch_record_exists? @imported_mbr_id
  end

end