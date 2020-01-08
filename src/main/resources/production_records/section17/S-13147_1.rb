# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq('test_widget_')
    @product_id = uniq('id_')
    @lot_number_one = uniq('lot_1_')
    @lot_number_two = uniq('lot_2_')
    @widget_type = @mc.production_widget_type.production_runtime_widget

    pre_test
    test_user_can_add_a_widget_to_the_dashboard
    test_user_can_edit_a_widget_in_the_dashboard
    test_user_can_delete_a_widget_from_the_dashboard
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    @mc.phase_step.add_date_time_step
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_one
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number_two
  end

  def test_user_can_add_a_widget_to_the_dashboard
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number_one, widget_id_number: 1)
    @mc.wait_for_video
    assert @mc.production_dashboard.widget_exists?(1), "The widget for #{@lot_number_one} was not added"
  end

  def test_user_can_edit_a_widget_in_the_dashboard
    @mc.production_dashboard.edit_widget 1
    @mc.production_runtime_widget.configure_widget(template: @master_template, lot: @lot_number_two)
    @mc.wait_for_video
    assert @mc.production_dashboard.verify_widget_text(@lot_number_two, 1),
           "Widget number 1 should include the text '#{@lot_number_two}' in its header."
  end

  def test_user_can_delete_a_widget_from_the_dashboard
    @mc.production_dashboard.delete_widget 1
    @mc.wait_for_video
    assert !@mc.production_dashboard.widget_exists?(1), 'The widget was not deleted.'
  end

  def clean_up
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end
end
