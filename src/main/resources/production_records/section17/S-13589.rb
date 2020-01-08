# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @admin_esig = env['admin_esig']
    @master_template = uniq('test_widget_')
    @product_id = uniq('id_')
    @lot_number_one = uniq('LOT_1_')
    @lot_number_two = uniq('LOT_2_')
    @lot_number_three = uniq('LOT_3_')
    @widget_type = @mc.production_widget_type.remaining_tasks_widget

    pre_test
    test_add_remaining_tasks_widgets_to_dashboard
    test_progress_bars_as_expected
    test_correct_number_of_production_records_appear
    test_completed_production_record_drops_to_bottom
    test_released_production_record_does_not_show_in_remaining_tasks_widget
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_one
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_two
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_three
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
  end

  def test_add_remaining_tasks_widgets_to_dashboard
    @mc.wait_for_video
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, detail_view: 'Operations',
                                         widget_id_number: 1)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, detail_view: 'Unit Procedures',
                                         widget_id_number: 2)
    @mc.production_dashboard.move_widget 2
  end

  def test_progress_bars_as_expected
    @mc.wait_for_video time: 1
    assert @mc.remaining_tasks_widget.progress_bar_current_value('1') == '1 Operations Remaining',
           "Widget number 1's progress bar label doesn't match the expected text."
    assert @mc.remaining_tasks_widget.progress_bar_current_value('2') == '1 Unit Procedures Remaining',
           "Widget number 2's progress bar label doesn't match the expected text."
  end

  def test_correct_number_of_production_records_appear
    @mc.remaining_tasks_widget.assert_number_of_widget_rows 1, 3
    @mc.remaining_tasks_widget.assert_number_of_widget_rows 2, 3
  end

  def test_completed_production_record_drops_to_bottom
    @mc.use_window 1
    fill_out_production_record
    @mc.use_window 2
    lot_name_at_bottom = @mc.remaining_tasks_widget.prod_record_attribute_at_row '1', '4', 'innerText'
    assert lot_name_at_bottom.include?(@lot_number_one),
           "Lot Name included in widget did not include #{@lot_number_one}"
  end

  def test_released_production_record_does_not_show_in_remaining_tasks_widget
    @mc.use_window 1
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.release_batch_record @admin, @admin_esig
    sleep 1
    @mc.use_window 2
    @mc.remaining_tasks_widget.assert_number_of_widget_rows 1, 2
    @mc.remaining_tasks_widget.assert_number_of_widget_rows 2, 2
  end

  def clean_up
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end

  private

  def fill_out_production_record
    @mc.ebr_navigation.go_to_first 'phase', @lot_number_one
    @mc.batch_phase_step.set_text('some text', '1.1.1.1')
    wait_until { @mc.batch_phase_step.complete_element.visible? }
    @mc.phase.completion.complete
    wait_until { @mc.batch_phase_step.performed_by_element.attribute('innerText').include? @admin }
  end
end
