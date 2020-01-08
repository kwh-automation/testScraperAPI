require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr


  def test_this
    @admin = env['admin_user']
    @password = env['password']
    @note_test_value = uniq('Phase Step Note Test Value 1')
    @product_name = uniq(@admin, false)
    @product_id = uniq(@admin, false)
    @limit1 = {'min' => 1, 'max' => 10}
    @limit2 = {'min' => 2, 'max' => 9}
    @min = 'min'
    @max = 'max'
    @label1 = 'limit 1'
    @label2 = 'limit 2'
    @form = 'ztest-mcml'
    @assert1 = 'Did not display label when it should have displayed'
    @assert2 = 'Did display limit when it should not have displayed'
    @assert3 = 'Warning should be present'
    @assert4 = 'Warning should not be present'

    pre_test
    test_warnings_will_trigger_on_calculation_phase_step
    test_warnings_will_trigger_on_table_view_for_calculation_limit
    test_limits_display_on_table_view
    test_warnings_will_no_longer_be_seen_once_inside_limit
    test_pdf_table_view_for_calculation
    test_pdf_phase_view_for_calculation
  end

  def pre_test
    @mc.do.login @admin, @password, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.phase_iterator
    @mc.phase_step.add_numeric
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.zero
    @mc.phase_step.calculation_step.save
    @mc.phase_step.numeric_data.enable_aggregation_types
    @mc.phase_step.numeric_data.choose_aggregation_type 'Sum'
    @mc.phase_step.enable_sum_limit
    @mc.modalgeneralnumericlimits.limit_label = @label1
    @mc.modalgeneralnumericlimits.set_minimum @limit1[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit1[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.numeric_data.limit_add
    @mc.modalgeneralnumericlimits.limit_label = @label2
    @mc.modalgeneralnumericlimits.disable_limit_displayed
    @mc.modalgeneralnumericlimits.set_minimum @limit2[@min]
    @mc.modalgeneralnumericlimits.set_maximum @limit2[@max]
    @mc.modalgeneralnumericlimits.save_limit
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @product_id
  end

  def test_warnings_will_trigger_on_calculation_phase_step
    @mc.ebr_navigation.go_to_first('phase', @product_id)
    @mc.batch_phase_step.start_new_iteration
    assert @mc.phase.phase_steps[1].agg_sum_display_limit(@label1).include?("#{@limit1[@min]} - #{@limit1[@max]}"), @assert1
    assert !@mc.phase.phase_steps[1].agg_sum_display_limit(@label2).include?("#{@limit2[@min]} - #{@limit2[@max]}"), @assert2
    @mc.phase.phase_steps[0].set_value 0
    @mc.phase.phase_steps[0].blur
    assert @mc.phase.phase_steps[1].agg_sum_limit_warning
  end

  def test_warnings_will_trigger_on_table_view_for_calculation_limit
    @mc.batch_phase_step.complete
    @mc.wait_for_video
    assert (@mc.iterating_phase_table_view.aggregration_sum_limit_warning? '1.1.1.2'), @assert3
  end

  def test_limits_display_on_table_view
    assert (@mc.iterating_phase_table_view.table_aggregration_sum_limit @label1), @assert1
    assert (!@mc.iterating_phase_table_view.table_aggregration_sum_limit @label2), @assert2
  end

  def test_warnings_will_no_longer_be_seen_once_inside_limit
    @mc.batch_phase_step.start_new_iteration
    assert @mc.phase.phase_steps[1].agg_sum_display_limit(@label1).include?("#{@limit1[@min]} - #{@limit1[@max]}"), @assert1
    assert !@mc.phase.phase_steps[1].agg_sum_display_limit(@label2).include?("#{@limit2[@min]} - #{@limit2[@max]}"), @assert2
    @mc.phase.phase_steps[0].set_value 5
    @mc.phase.phase_steps[0].blur
    assert !@mc.phase.phase_steps[1].agg_sum_limit_warning, @assert4
    @mc.batch_phase_step.complete
    @mc.wait_for_video
    assert (!@mc.iterating_phase_table_view.aggregration_sum_limit_warning? '1.1.1.2'), @assert4
    assert (@mc.iterating_phase_table_view.table_aggregration_sum_limit @label1), @assert1
    assert (!@mc.iterating_phase_table_view.table_aggregration_sum_limit @label2), @assert2
    @mc.iterating_phase_table_view.click_data_table_iteration 1
    @mc.batch_phase_step.launch_phase_form '1.1.1.2', step: 2
    @mc.batch_record_form_launch.select_form '1.1.1.2', form: @form
    @mc.batch_record_form_launch.launch phase_step: '1.1.1.2'
  end

  def test_pdf_table_view_for_calculation
    @mc.do.move_downloaded_files '', 'pdf'
    @mc.ebr_navigation.options_dropdown
    @mc.ebr_navigation.view_pdf
    downloaded_pdf_file_name = get_downloaded_pdf_name
    @mc.pdf.open_downloaded_pdf downloaded_pdf_file_name
    @mc.pdf.go_to_page page_number: 3
    assert (@mc.pdf.find_text(@label1) && @mc.pdf.get_words_on_page(page_number: 3).include?(@label1)), @assert1
  end
  
  def test_pdf_phase_view_for_calculation
    @mc.pdf.go_to_page page_number: 4
    assert (@mc.pdf.find_text(@label1) && @mc.pdf.get_words_on_page(page_number: 4).include?(@label1)), @assert1
    assert !@mc.pdf.find_text(@label2), @assert2
  end
end
