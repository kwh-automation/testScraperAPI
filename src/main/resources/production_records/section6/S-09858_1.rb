require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @txt_sample = "This is some sample text."
    @product_id = uniq("1", false)
    @mbr_name = uniq("custom_header_br")
    @lot_number = uniq("lot_", true)
    @original_header_1 = "New Header 1"
    @original_header_2 = "New Header 2"
    @updated_header_1 = "Updated Header 1"
    @updated_header_2 = "Updated Header 2"
    @original_content_1 = "New Content 1"

    pre_test
    test_master_template_custom_headers_appear_in_production_record
    test_user_can_add_new_content_with_existing_label
    test_user_cannot_edit_existing_content
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure @mbr_name, @product_id
    @mc.structure_builder.edit_mbr.select_release_role
    custom_header_build
  end

  def test_master_template_custom_headers_appear_in_production_record
    assert @mc.batch_record_headers.header_label(@original_header_1) == @original_header_1
    assert @mc.batch_record_headers.header_content(@original_header_1) == @original_content_1
    assert @mc.batch_record_headers.header_label(@original_header_2) == @original_header_2
  end

  def test_user_can_add_new_content_with_existing_label
    @mc.batch_record_headers.add_br_header_content id: @original_header_2, set_content: @txt_sample
    assert @mc.batch_record_headers.header_content(@original_header_2) == @txt_sample
  end

  def test_user_cannot_edit_existing_content
    assert @mc.batch_record_headers.not_editable? @original_header_1
  end

    private
  def custom_header_build
    @mc.structure_builder.edit_mbr.header_settings.add_mbr_headers enable: true,
                                                                       id: 1,
                                                                set_label: @original_header_1,
                                                              set_content: @original_content_1,
                                                                     save: false

    @mc.structure_builder.edit_mbr.header_settings.add_mbr_headers     id: 2,
                                                               add_header: true,
                                                                set_label: @original_header_2

    @mc.structure_builder.procedure_level.add_unit set_name: "Unit Procedure 1"
    @mc.structure_builder.operation_level.add_unit set_name: "Operation 1"
    @mc.structure_builder.phase_level.add_unit set_name: "Phase 1"
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number
    @mc.go_to.ebr
    @mc.ebr.batch_record_search_input = @lot_number
    @mc.ebr.batch_record_go
  end

end