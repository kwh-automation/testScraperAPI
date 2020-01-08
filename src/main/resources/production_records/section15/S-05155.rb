# frozen_string_literal: true

require 'mastercontrol-test-suite'
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @esig = env['admin_esig']
    @first_data = uniq('First')
    @lone_correctable_text = "I'm wrong alone"
    @lone_correction_text = "I'm right alone"
    @lone_note = 'Lone note'
    @combined_correctable_text = "I'm wrong with a note"
    @combined_correction_text = "I'm right with a note"
    @combined_note = "I'm a note that's not alone."

    pre_test
    test_that_iterations_with_notes_or_corrections_listed_in_pdf
  end

  def pre_test
    @connection = MCAPI.new
    create_batch_record

    @mc.do.login @admin, @admin_pass, connection: @connection, approve_trainee: true
    @mc.ebr_navigation.go_to_first 'phase', @lot_number
    wait_until { @mc.batch_phase_step.start_new_iteration_element.visible? }
    @mc.batch_phase_step.start_new_iteration
    complete_a_step @first_data
    @mc.batch_phase_step.start_new_iteration
    complete_a_step @lone_correctable_text, false
    @mc.phase.phase_steps[0].start_correction
    wait_until { @mc.phase.phase_steps[0].correction.submit_correction_element.visible? }
    @mc.phase.phase_steps[0].set_text @lone_correction_text
    @mc.phase.phase_steps[0].correction.submit_correction
    wait_until { @mc.phase.phase_steps[0].correction.date != '' }
    @mc.phase.phase_steps[0].correction.finish_correction
    @mc.phase.completion.complete
    @mc.batch_phase_step.start_new_iteration
    @mc.phase.phase_steps[0].show_notes
    @mc.phase.phase_steps[0].notes.add
    @mc.phase.phase_steps[0].notes.set_text @lone_note
    @mc.phase.phase_steps[0].notes.save
    wait_until { !@mc.phase.phase_steps[0].notes.save_note_element.visible? }
    complete_a_step 'Third?'
    @mc.batch_phase_step.start_new_iteration
    complete_a_step @combined_correctable_text, false
    @mc.phase.phase_steps[0].show_notes
    @mc.phase.phase_steps[0].notes.add
    @mc.phase.phase_steps[0].notes.set_text @combined_note
    @mc.phase.phase_steps[0].notes.save
    @mc.phase.phase_steps[0].start_correction
    @mc.phase.phase_steps[0].set_text @combined_correction_text
    @mc.phase.phase_steps[0].correction.submit_correction
    wait_until { @mc.phase.phase_steps[0].correction.date != '' }
    @mc.phase.phase_steps[0].correction.finish_correction
    @mc.phase.completion.complete
  end

  def test_that_iterations_with_notes_or_corrections_listed_in_pdf
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.do.move_downloaded_files '', 'pdf'
    @mc.batch_record_list.view_batch_record_pdf @lot_number
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name, check_file: true
    @mc.hide_window
    @mc.wait_for_video
    assert @mc.pdf.find_text(@combined_correction_text)
    @a_page = @mc.pdf.current_page_num
    @mc.pdf.go_to_page
    assert @mc.pdf.find_text(@lone_note)
    @mc.wait_for_video
    @b_page = @mc.pdf.current_page_num
    @mc.wait_for_video
    assert a_precedes_b_in_pdf? @combined_correction_text, @lone_note
    assert @mc.pdf.find_text(@lone_correction_text), "#{@lone_correction_text} was not found, but it should have been."
    @mc.wait_for_video
  end

  def clean_up
    @mc.pdf.close
    @mc.pdf.cleanup_downloads File.expand_path("#{ENV['USERPROFILE']}/downloads")
  end

  private

  def create_batch_record
    mbr_json = PhaseFactory.phase_customizer
                           .with_phase_step(GeneralTextBuilder.new
                                        .with_correction_configuration(CorrectionConfigurationBuilder.new.build)
                                        .with_notes.with_maximum_length(30))
                           .with_iterate_by(1).build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_master_batch_record_json(mbr_json)
                                                 .with_quantity(4)
                                                 .with_connection(@connection)
                                                 .build

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end

  def complete_a_step input, complete = true
    @mc.phase.phase_steps[0].set_text input
    @mc.phase.phase_steps[0].blur
    @mc.phase.completion.complete if complete
  end

  def a_precedes_b_in_pdf? a, b
    if @a_page < @b_page
      true
    elsif @a_page == @b_page
      @mc.pdf.phrase_precedes_phrase? @a_page, a, b
    else
      false
    end
  end
end
