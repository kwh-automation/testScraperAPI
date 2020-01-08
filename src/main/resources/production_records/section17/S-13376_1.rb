# frozen_string_literal: true

require 'mastercontrol-test-suite'
class DashboardWidget < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template_one = uniq('1_master_template_', false)
    @master_template_two = uniq('2_master_template_', false)
    @product_id = uniq('id_')
    @lot_number_one = uniq('lot_1_')
    @lot_number_two = uniq('lot_2_')
    @unit_procedure_one = uniq('first_unit_procedure_', false)
    @unit_procedure_two = uniq('second_unit_procedure_', false)
    @operation_1_1 = uniq('first_operation_', false)
    @common_operation = uniq('common_operation_', false)
    @operation_2_1 = uniq('third_operation_', false)
    @widget_type = @mc.production_widget_type.in_process_mt_widget

    pre_test
    test_user_can_select_operation_or_unit_procedure_data_to_display
    test_user_can_search_for_an_operation_or_unit_procedure_name
    test_widget_shows_master_templates_with_production_records_in_the_specified_process
    test_master_template_no_longer_displays_when_its_production_records_are_no_longer_in_the_specified_process
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    create_master_template @master_template_one
    create_master_template @master_template_two
    @mc.do.create_batch_record "#{@product_id} #{@master_template_one}", @lot_number_one
    @mc.do.create_batch_record "#{@product_id} #{@master_template_two}", @lot_number_two
    advance_production_record @lot_number_one, '1.1.1', 1
  end

  def test_user_can_select_operation_or_unit_procedure_data_to_display
    @mc.go_to.ebr.production_dashboard
    @mc.use_window 2
    @mc.dashboard_widget_util.add_widget(type: @widget_type, search_text: @unit_procedure_one, sub_type: 'Unit Procedure',
                                         widget_id_number: 1, slow_for_video: true)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, search_text: @operation_1_1, sub_type: 'Operation',
                                         widget_id_number: 2, slow_for_video: true)
  end

  def test_user_can_search_for_an_operation_or_unit_procedure_name
    @mc.dashboard_widget_util.add_widget(type: @widget_type, search_text: @unit_procedure_two,
                                         sub_type: 'Unit Procedure', widget_id_number: 3)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, search_text: @operation_2_1,
                                         sub_type: 'Operation', widget_id_number: 4)
    @mc.dashboard_widget_util.add_widget(type: @widget_type, search_text: @common_operation,
                                         sub_type: 'Operation', widget_id_number: 5)
  end

  def test_widget_shows_master_templates_with_production_records_in_the_specified_process
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, false, false, false, false, false
    advance_production_record @lot_number_two, '1.1.1', 1
    advance_production_record @lot_number_two, '1.2.1', 1
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, true, true, false, false, true
    advance_production_record @lot_number_two, '2.1.1', 2
    advance_production_record @lot_number_two, '2.2.1', 2
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, true, true, true, true, true
  end

  def test_master_template_no_longer_displays_when_its_production_records_are_no_longer_in_the_specified_process
    advance_production_record @lot_number_two, '1.1.1', 2
    @mc.phase.completion.complete
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, true, false, true, true, true
    advance_production_record @lot_number_two, '1.2.1', 2
    @mc.phase.completion.complete
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, false, false, true, true, true
    advance_production_record @lot_number_two, '2.1.1', 1
    @mc.phase.completion.complete
    run_asserts @master_template_one, true, true, false, false, false
    run_asserts @master_template_two, false, false, true, false, true
    advance_production_record @lot_number_one, '1.2.1', 2
    advance_production_record @lot_number_two, '2.2.1', 1
    @mc.phase.completion.complete
    run_asserts @master_template_one, true, true, false, false, true
    run_asserts @master_template_two, false, false, false, false, false
  end

  def clean_up
    @mc.dashboard_widget_util.remove_all_widgets_db_cleanup @admin
  end

  private

  def create_master_template master_template
    @mc.ebr.open_new_mbr_structure master_template, @product_id, lot_number_configuration: 'Manually Enter on Production Record'
    @mc.structure_builder.edit_mbr.select_release_role role_name: env['test_admin_role']
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.success.displayed
    create_unit_procedure @unit_procedure_one, @operation_1_1, @common_operation
    create_unit_procedure @unit_procedure_two, @operation_2_1, @common_operation
    @mc.do.publish_master_batch_record master_template, @product_id
  end

  def create_unit_procedure unit_procedure, operation1, operation2
    @mc.structure_builder.procedure_level.add_unit set_name: unit_procedure
    [operation1, operation2].each do |operation|
      @mc.structure_builder.operation_level.add_unit set_name: operation
      @mc.structure_builder.phase_level.add_unit set_name: "Phase_in_#{operation}"
      @mc.structure_builder.phase_level.configure_phase 1
      @mc.phase_step.add_completion_step
      @mc.phase_step.add_completion_step
      @mc.phase_step.back
    end
  end

  def advance_production_record lot_number, label, step
    @mc.use_window 1
    @mc.go_to.ebr
    @mc.ebr.batch_record_search_input = lot_number
    @mc.ebr.batch_record_go
    @mc.ebr_navigation.sidenav_navigate_to label
    @mc.phase.phase_steps[step - 1].complete
    wait_until { @mc.phase.phase_steps[step - 1].completed? }
  end

  def run_asserts text, widget1, widget2, widget3, widget4, widget5
    @mc.use_window 2
    num = 0
    [widget1, widget2, widget3, widget4, widget5].each do |should_appear|
      num += 1
      if should_appear
        wait_to_appear text, num
        assert @mc.production_dashboard.verify_widget_text(text, num), "Widget number #{num} should have #{text} in the list."
      else
        wait_to_disappear text, num
        assert !(@mc.production_dashboard.verify_widget_text text, num),
               "Widget number #{num} should not have #{text} in the list."
      end
    end
  end

  def wait_to_appear text, num
    seconds = 0
    while !(@mc.production_dashboard.verify_widget_text text, num) && seconds < 60
      sleep 1
      seconds += 1
    end
  end

  def wait_to_disappear text, num
    seconds = 0
    while (@mc.production_dashboard.verify_widget_text text, num) && seconds < 60
      sleep 1
      seconds += 1
    end
  end
end
