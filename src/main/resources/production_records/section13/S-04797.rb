require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @esig = env["admin_esig"]
    @lot_number = uniq("4797")
    @order_label = uniq("1.1.1.1")
    @title = uniq("S-04797")
    @product_id = uniq("prod_id")
    @product_name = uniq("name")
    @small_text_content = "tiny"
    @doc_number = uniq("doc_", false)
    @infocard_text = uniq("infocard", false)
    @custom_link_url = "https://www.google.com"
    @custom_link = "custom"

    pre_test
    test_authorized_users_can_sign_off_on_production_record
    test_user_info_displayed_when_completing_signoff
    test_status_set_to_released_after_added_to_master_template_infocard
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc_number, file_name: resource("small_text")
    @mc.infocard.quick_approve env['password'], env['admin_esig']
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    wait_until { @mc.phase_step._add_instruction_element.visible? }
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @infocard_text + "  " + @custom_link
    @infocard_link = (@mc.phase_step.instructions.add_infocard_link @infocard_text, @doc_number)
    @mc.phase_step.instructions.add_hyperlink @custom_link, @custom_link_url
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record "#{@product_id} #{@product_name}"
    @mc.batch_record_creation.lot_number = @lot_number
    @mc.batch_record_creation.lot_amount = 1
    @mc.batch_record_creation.create
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    @mc.phase.phase_steps[0].autocomplete
    only_production_records_that_are_data_complete_can_be_released
  end


  def test_authorized_users_can_sign_off_on_production_record
    @mc.batch_record_list.review_by_exception @lot_number
    released_by_signed = @mc.reviewandrelease.complete_released_by @admin, @esig
    assert released_by_signed
  end

  def test_user_info_displayed_when_completing_signoff
    assert wait_until{@mc.reviewandrelease.released_by_info_displayed @admin}
  end

  def test_status_set_to_released_after_added_to_master_template_infocard
    expected_status = "Released"
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    wait_until{@mc.batch_record_list.batch_record_status_is? @lot_number, expected_status}
    is_status_released = @mc.batch_record_list.batch_record_status_is? @lot_number, expected_status
    assert is_status_released
  end

  private
  def only_production_records_that_are_data_complete_can_be_released
    @mc.go_to.ebr.batch_records_data_complete
    assert !@mc.batch_record_list.in_list?(@product_id)
    @mc.ebr_navigation.go_to_first "phase", @lot_number
    @mc.phase.completion.complete
    @mc.do.check_time(@mc.phase.completion.date)
    @mc.go_to.ebr
    @mc.ebr.batch_records_data_complete
    assert @mc.batch_record_list.in_list? @product_id
  end

end