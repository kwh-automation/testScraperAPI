require "mastercontrol-test-suite"

class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @lot_number = uniq("lot_", true)
    @doc_number = uniq("doc_")
    @mbr_name = uniq("Doc_attachment_test_")
    @product_id = uniq("Doc_attachment_id_")
    @instructions = "Testing"

    pre_test
    test_signatures_of_users_entering_data_appear_on_accountability_page_when_configured
    test_documents_attached_to_Master_Template_display_on_accountability_page_when_configured
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_document_infocard @doc_number, username: @admin, esig: env["admin_esig"]
    @mc.do.create_master_batch_record @mbr_name, @product_id, open_phase_builder: true, enable_accountability_settings: true
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @instructions
    @mc.phase_step.instructions.add_infocard_link @instructions, @doc_number
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step_hyperlink.add_document_to_hyperlink @doc_number
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    finish_mbr_create_br
  end

  def test_signatures_of_users_entering_data_appear_on_accountability_page_when_configured
    @mc.phase.phase_steps[1].set_text "Testing Data Capture"
    @mc.phase.phase_steps[1].blur
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    assert @mc.accountability.verify_signature_row @admin, 1
  end

  def test_documents_attached_to_Master_Template_display_on_accountability_page_when_configured
    assert @mc.accountability.document_linked? 1
    assert @mc.accountability.document_linked? 2
    @mc.accountability.open_phase 1
    @mc.use_window 2
    wait_until{@mc.phase.phase_steps[0].phase_header_element.visible?}
    assert (@mc.phase.phase_steps[0].phase_header_element.text.include? "Phase 1")
  end

    private
  def finish_mbr_create_br
    @mc.do.publish_master_batch_record @mbr_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number
    @mc.go_to.ebr
    @mc.ebr.batch_record_search_input = @lot_number
    @mc.ebr.batch_record_go
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
  end

end
