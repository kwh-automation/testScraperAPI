require "mastercontrol-test-suite"
require 'fileutils'
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("mt")
    @prod_id = uniq("prod")
    @lot_number = uniq("lot")
    @corrected_text = uniq("correct_")
    @file_to_upload = "#{env['resource_dir']}/eBRLabsInc.png"

    pre_test
    test_that_steps_with_correction_display_in_gadget
    test_that_steps_with_attachments_display_in_gadget
    test_that_attachments_are_displayed_in_gadget
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true

    @mc.do.create_master_batch_record @mbr_name, @prod_id, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.add_general_text
    @mc.phase_step.add_attachment_step
    @mc.phase_step.add_attachment_step
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.add_pass_fail_step
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
    @mc.phase.phase_steps[1].autocomplete
    @mc.phase.phase_steps[1].start_correction
    wait_until { @mc.phase.phase_steps[1].correction.submit_correction_element.visible? }
    @mc.phase.phase_steps[1].set_text @corrected_text
    @mc.phase.phase_steps[1].correction.submit_correction
    wait_until{@mc.phase.phase_steps[1].correction.date != ""}
    @mc.phase.phase_steps[1].correction.finish_correction

    @mc.phase.phase_steps[2].attach @file_to_upload
    wait_until{@mc.phase.phase_steps[2].date != ""}
    @mc.phase.phase_steps[4].select_pass
    @mc.phase.phase_steps[5].select_fail
  end

  def test_that_steps_with_correction_display_in_gadget
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.toggle_gadget 1
    @mc.review_by_exception.toggle_gadget 3
    wait_until{@mc.review_by_exception.phase_step_is_listed? "1.1.1.2"}
    assert @mc.review_by_exception.phase_step_is_listed?( "1.1.1.2")
  end

  def test_that_steps_with_attachments_display_in_gadget
    @mc.review_by_exception.toggle_gadget 2
    sleep 1
    @mc.review_by_exception.toggle_gadget 4
    wait_until{@mc.review_by_exception.phase_step_is_listed? "1.1.1.3"}
    assert @mc.review_by_exception.phase_step_is_listed?("1.1.1.3")
  end

  def test_that_attachments_are_displayed_in_gadget
    assert @mc.review_by_exception.attachment_is_displayed?
  end

end