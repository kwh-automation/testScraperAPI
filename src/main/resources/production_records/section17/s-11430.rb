# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq('test_widget_')
    @product_id = uniq('id_')
    @lot_number = uniq('lot_1_')
    @widget_type = @mc.production_widget_type.production_runtime_widget

    pre_test
    test_resizing_widget
    test_rearranging_widget
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    @mc.phase_step.add_date_time_step
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
    (1..5).each do |num|
      @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number, widget_id_number: num)
    end
  end

  def test_resizing_widget
    @mc.wait_for_video time: 1
    @mc.production_dashboard.resize_widget 1, up_or_down: 3
    @mc.wait_for_video time: 1
    @mc.production_dashboard.resize_widget 5, up_or_down: -1
  end

  def test_rearranging_widget
    @mc.wait_for_video time: 1
    @mc.production_dashboard.move_widget 2
    @mc.wait_for_video time: 1
    @mc.production_dashboard.move_widget 4
  end

  def clean_up
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end
end
