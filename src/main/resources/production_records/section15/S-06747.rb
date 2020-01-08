require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @watermark_text = "REJECTED"
    @mbr_name = uniq("mt")
    @prod_id = uniq("prod")
    @lot_number = uniq("lot")

    pre_test
    test_pdf_has_rejected_watermark
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true

    @mc.do.create_master_batch_record @mbr_name, @prod_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text "To be cancelled for testing"
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @mbr_name, @prod_id

    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record "#{@prod_id} #{@mbr_name}"
    @mc.batch_record_creation.lot_number = @lot_number
    @mc.batch_record_creation.lot_amount = "15"
    @mc.batch_record_creation.create
    @mc.ebr_navigation.go_to_first "phase", @lot_number
    @mc.phase.phase_steps[0].autocomplete

    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    @mc.batch_record_list.review_by_exception @lot_number
    @mc.review_by_exception.emergency_reject_batch_record @admin
    @mc.do.move_downloaded_files "", "pdf"
  end

  def test_pdf_has_rejected_watermark
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    wait_until { @mc.batch_record_list.batch_record_status_is?(@lot_number, "Rejected") }
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
    @mc.hide_window
    assert @mc.pdf.advanced_ui_search(@watermark_text, case_sensitive: true), "Unable to find '#{@watermark_text}'"
    @mc.wait_for_video
    @mc.pdf.close
  end

  def clean_up
    @mc.pdf.close
  end

end