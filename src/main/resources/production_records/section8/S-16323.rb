require "mastercontrol-test-suite"
class EbrFRS < MCFunctionalTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_signoff = 's-16323'
    @admin_pass = env['password']
    @lot_number = uniq('')
    @MBR_name = uniq('Highlighting')
    @MBR_id = uniq('id')
    @phase_step_1 = '1.1.1.1'
    @phase_step_2 = '1.1.1.2'
    @text = 'text'
    @corrected_value = 'I am correct'
    @user = uniq('user_')
    @connection = MCAPI.new
    @esig = '2'

    pre_test
    test_row_headers_and_cells_with_incomplete_data_are_highlighted
    test_cells_with_incomplete_corrections_are_highlighted
  end

  def pre_test
    MCAPIs.create_user @user, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees @user, connection: @connection
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @MBR_name, @MBR_id, open_phase_builder:true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_witness
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_witness
    @mc.phase_builder.phase_iterator
    @mc.wait_for_video
    @mc.phase_step.general_text.back
    @mc.do.publish_master_batch_record @MBR_name, @MBR_id
    @mc.do.create_batch_record "#{@MBR_id} #{@MBR_name}", @lot_number
    @mc.ebr_navigation.go_to_first('Phase', @lot_number)
  end

  def test_row_headers_and_cells_with_incomplete_data_are_highlighted
    @mc.batch_phase_step.start_new_iteration
    @mc.batch_phase_step.set_text @text, @phase_step_1
    @mc.phase.phase_steps[0].witness.username.send_keys @user
    @mc.phase.phase_steps[0].witness.esignature.send_keys @esig
    @mc.phase.phase_steps[0].witness.submit

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert @mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert @mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    assert @mc.iterating_phase_table_view.check_incomplete_completed_by_highlight

    @mc.iterating_phase_table_view.click_data_table_iteration 1
    @mc.batch_phase_step.set_text @text, @phase_step_2
    @mc.phase.phase_steps[1].witness.username.send_keys @user
    @mc.phase.phase_steps[1].witness.esignature.send_keys @esig
    @mc.phase.phase_steps[1].witness.submit

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert !@mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert @mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    assert @mc.iterating_phase_table_view.check_incomplete_completed_by_highlight

    @mc.iterating_phase_table_view.click_data_table_iteration 1
    @mc.batch_phase_step.complete

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert !@mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert !@mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    assert !@mc.iterating_phase_table_view.check_incomplete_completed_by_highlight
  end

  def test_cells_with_incomplete_corrections_are_highlighted
    @mc.iterating_phase_table_view.click_data_table_iteration 1
    @mc.phase.phase_steps[1].start_correction

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert @mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert @mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    @mc.iterating_phase_table_view.click_data_table_iteration 1

    @mc.phase.phase_steps[1].set_text @corrected_value
    @mc.phase.phase_steps[1].correction.submit_correction
    wait_until{@mc.phase.phase_steps[1].correction.performer.include? @admin_signoff}
    @mc.phase.phase_steps[1].correction.finish_correction

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert @mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert @mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    @mc.iterating_phase_table_view.click_data_table_iteration 1

    @mc.phase.phase_steps[1].witness.username.send_keys @user
    @mc.phase.phase_steps[1].witness.esignature.send_keys @esig
    @mc.phase.phase_steps[1].witness.submit

    @mc.batch_phase_step.table_view
    @mc.wait_for_video
    assert !@mc.iterating_phase_table_view.check_incomplete_highlighted_table_cell
    assert !@mc.iterating_phase_table_view.check_incomplete_row_highlight(0)
    assert !@mc.iterating_phase_table_view.check_incomplete_completed_by_highlight
  end
end
