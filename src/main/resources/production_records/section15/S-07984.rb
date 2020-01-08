require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("job_")
    @lot_number = uniq("imalot_")
    @step_1_text = uniq("step1_", false)
    @step_2_initial = uniq("I'm Wrong ", false)
    @step_2_corrected = uniq("I'm right ", false)
    @instruction_note = "These instructions are bad"
    @step_1_note = "Step 1, best step"
    @correction_note = "This step was done poorly"

    pre_test
    test_rendering_production_record_to_pdf
    test_that_page_numbering_is_x_of_y_format
    test_that_phase_steps_display_current_value
    test_that_user_notes_are_displayed
    test_that_corrections_are_displayed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_name, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.enable_notes
    @mc.phase_step.add_general_text
    @mc.phase_step.enable_notes
    @mc.phase_step.enable_correction_reason
    @mc.phase_step.enable_correction_note
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text "To be rendered"
    @mc.phase_step.enable_notes
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_name
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record "#{@product_name} #{@product_name}"
    @mc.batch_record_creation.lot_number = @lot_number
    @mc.batch_record_creation.lot_amount = "1"
    @mc.batch_record_creation.create
    @mc.ebr_navigation.go_to_first "phase", @lot_number
    @mc.phase.instructions.show_notes
    @mc.phase.instructions.notes.add note_text: @instruction_note
    @mc.phase.phase_steps[0].show_notes
    @mc.phase.phase_steps[0].notes.add note_text: @step_1_note
    @mc.phase.phase_steps[0].set_text @step_1_text
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[1].set_text @step_2_initial
    @mc.phase.phase_steps[1].blur
    @mc.phase.phase_steps[1].start_correction
    wait_until { @mc.phase.phase_steps[1].correction.submit_correction_element.visible? }
    @mc.phase.phase_steps[1].set_text @step_2_corrected
    @mc.phase.phase_steps[1].correction.submit_correction
    wait_until{@mc.phase.phase_steps[1].correction.date != ""}
    @mc.phase.phase_steps[1].correction.correction_notes.add note_text: @correction_note
    @mc.phase.phase_steps[1].correction.finish_correction
    @mc.phase.completion.complete
  end

  def test_rendering_production_record_to_pdf
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    @mc.do.move_downloaded_files "", "pdf"
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
  end

  def test_that_page_numbering_is_x_of_y_format
    @mc.hide_window
    total = @mc.pdf.get_total_pages
    @mc.pdf.go_to_page
    assert @mc.pdf.find_text("1 of #{total}")
  end

  def test_that_phase_steps_display_current_value
    @mc.pdf.go_to_page page_number: 2
    assert @mc.pdf.find_text(@step_1_text), "Could not find #{@step_1_text}"
    assert @mc.pdf.find_text(@step_2_corrected), "Could not find #{@step_2_corrected}"
  end

  def test_that_user_notes_are_displayed
    assert @mc.pdf.find_text(@instruction_note), "Could not find #{@instruction_note}"
    assert @mc.pdf.find_text(@step_1_note), "Could not find #{@step_1_note}"
  end

  def test_that_corrections_are_displayed
    assert @mc.pdf.find_text("Correction")
    assert @mc.pdf.find_text(@step_2_corrected)
    assert @mc.pdf.find_text(@correction_note), "Could not find #{@correction_note}"
  end

  def clean_up
    @mc.pdf.close
  end

end