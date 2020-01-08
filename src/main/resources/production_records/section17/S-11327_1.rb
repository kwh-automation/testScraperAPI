# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @shortest_timeout = '5 minutes'
    @default_timeout = '2 hours'
    @master_template = uniq('test_widget_')
    @product_id = uniq('id_')
    @lot_number = uniq('lot_1_')
    @widget_type = @mc.production_widget_type.production_runtime_widget

    pre_test
    test_dashboard_can_be_configured_to_not_allow_session_timeout
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.portal.home_and_login
    @mc.home_and_login_pages.global_lockout_time = @shortest_timeout
    @mc.home_and_login_pages.session_expiration_time = @shortest_timeout
    sleep 1
    @mc.home_and_login_pages.save
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    @mc.phase_step.add_date_time_step
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number
  end

  def test_dashboard_can_be_configured_to_not_allow_session_timeout
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number, widget_id_number: 1)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, template: @master_template, lot: @lot_number, widget_id_number: 2)
    @mc.production_dashboard.enable_persistent_session
    sleep 302
    @mc.production_dashboard.delete_widget 1
    assert @mc.production_dashboard.add_new_widget_element.visible?, 'The session timed out.'
  end

  def clean_up
    @mc.do.login @admin, @admin_pass
    @mc.go_to.portal.home_and_login
    @mc.home_and_login_pages.session_expiration_time = @default_timeout
    @mc.home_and_login_pages.global_lockout_time = @default_timeout
    @mc.home_and_login_pages.save
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end
end
