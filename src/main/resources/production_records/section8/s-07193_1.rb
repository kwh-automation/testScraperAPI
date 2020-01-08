require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @lot_number = uniq("")
    @test_mbr = "#{env["mbr_product_id"]} #{env["mbr_product_name"]}"
    @lot_amount = 3

    pre_test
    test_more_than_minimum_loops_can_be_done
    test_minimum_started_and_completed_iterations_display
    test_viewing_table_view
    test_only_final_values_display_in_table
    test_navigating_to_existing_iterations
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_batch_record @test_mbr, @lot_number, lot_amount: @lot_amount
    @mc.ebr_navigation.go_to_phase @lot_number, 2, custom_name:"Iterative_phase"
  end

  def test_more_than_minimum_loops_can_be_done
    (@lot_amount + 1).times do |i|
      complete_data_iteration "data_#{i + 1}"
    end

    @required = @mc.count_summary.required_rows
    @completed = @mc.count_summary.completed_rows
    @open = @mc.count_summary.open_rows
    assert (@completed > @required), "#{@completed} was not greater than #{@required}"
  end

  def test_minimum_started_and_completed_iterations_display
    assert @required == 3
    assert @completed == 4
    assert @open == 0
  end

  def test_viewing_table_view
    @mc.batch_phase_step.table_view
    @step_one_data = @mc.iterating_phase_table_view.get_row_as_string 1
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(1) == "data_1"
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(2) == "data_2"
  end

  def test_only_final_values_display_in_table
    @mc.ebr_navigation.go_to_phase @lot_number, 2, custom_name: "Iterative_phase"
    complete_data_iteration "Iteration_1"
    complete_data_iteration "Iteration_2"
    complete_data_iteration "incorrected", complete: false
    @mc.phase.phase_steps[0].start_correction
    wait_until { @mc.phase.phase_steps[0].correction.submit_correction_element.visible? }
    @mc.phase.phase_steps[0].set_text "corrected"
    @mc.phase.phase_steps[0].correction.submit_correction
    wait_until{@mc.phase.phase_steps[0].correction.date != ""}
    @mc.phase.phase_steps[0].correction.finish_correction
    @mc.batch_phase_step.complete
    @mc.batch_phase_step.table_view
    assert @mc.iterating_phase_table_view.get_data_capture_value_by_iteration(7).include? "corrected"
    assert !@mc.iterating_phase_table_view.get_data_capture_value_by_iteration(7).include?("incorrected")
  end

  def test_navigating_to_existing_iterations
    @mc.iterating_phase_table_view.click_data_table_iteration 5
    sleep 2
    assert @mc.batch_phase_step.entered_data_element.attribute('innerText') == "Iteration_1"
    @mc.batch_phase_step.table_view
    @mc.iterating_phase_table_view.click_data_table_iteration 6
    sleep 2
    assert @mc.batch_phase_step.entered_data_element.attribute('innerText') == "Iteration_2"
  end

  private
  def complete_data_iteration text, phase_step:"1.2.1.1", complete: true
    @mc.iterating_phase_table_view.start_new_row
    begin
      @mc.batch_phase_step.set_text text, phase_step
    rescue
      warning "Element may be stale"
    end
    if complete
      sleep 2
      wait_until(10){@mc.iterating_phase_table_view.data_captured?}
      @mc.batch_phase_step.complete
      sleep 2
    end
  end
end
