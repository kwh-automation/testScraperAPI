# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @esig = env['admin_esig']
    @master_template = uniq('test_widget_')
    @product_id = uniq('id_')
    @lot_number_one = uniq('lot_1_')
    @lot_number_two = uniq('lot_2_')
    @lot_number_three = uniq('lot_3_')
    @widget_type = @mc.production_widget_type.production_runtime_widget

    pre_test
    test_user_can_select_a_production_record_based_on_a_master_template
    test_production_record_information_is_displayed_on_the_widget
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    @mc.phase_step.add_date_time_step
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_one
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_two
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_three
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
  end

  def test_user_can_select_a_production_record_based_on_a_master_template # First widget addition intentionally slow for validation video
    @mc.production_dashboard.add_widget
    @mc.widget_modal.select_type @widget_type
    @mc.production_runtime_widget.select_master_template_element.click
    @mc.wait_for_video time: 1
    @mc.production_runtime_widget.select_template @master_template
    @mc.production_runtime_widget.select_lot_element.click
    @mc.wait_for_video time: 1
    @mc.production_runtime_widget.select_lot @lot_number_one
    @mc.wait_for_video time: 1
    @mc.production_runtime_widget.complete_modal
    @widget_one_text = @mc.production_dashboard.widget_text(1)
    @mc.wait_for_video
    assert @mc.production_dashboard.verify_widget_text(@lot_number_one, 1),
           "Widget number 1 should include the text '#{@lot_number_one}' in its header; found '#{@widget_one_text}'"
  end

  def test_production_record_information_is_displayed_on_the_widget
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number_two, widget_id_number: 2)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number_three, widget_id_number: 3)
    complete_production_record @lot_number_one
    @mc.wait_for_video
    complete_production_record @lot_number_two
    %w[current fastest average slowest].each do |type|
      assert @mc.production_runtime_widget.verify_time_bar_exists(type, widget_id_number: 3),
             "#{type} time is not shown on the widget"
    end
  end

  def clean_up
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end

  private

  def complete_production_record lot_number
    @mc.use_window 1
    @mc.ebr_navigation.go_to_first 'phase', lot_number
    @mc.phase.phase_steps[0].complete
    wait_until { @mc.phase.phase_steps[0].completed? }
    @mc.phase.completion.complete
    @mc.ebr_navigation.review_by_exception
    @mc.reviewandrelease.complete_released_by @admin, @esig
    @mc.use_window 2
  end
end
