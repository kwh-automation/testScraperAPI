# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('lot_', true)
    @form_one = env['sample_form_workflow']
    @form_two = env['sample_form_workflow']
    @form_three = env['sample_form_workflow']
    @connection = MCAPI.new
    @operation_one = 'Operation 1'
    @operation_two = 'Operation 2'
    @operation_three = 'Operation 3'
    @phase_one = 'Phase 1'
    @phase_two = 'Phase 2'
    @phase_three = 'Phase 3'
    @unit_procedure_order_label = '1'
    @operation_one_order_label = '1.1'
    @operation_two_order_label = '1.2'
    @operation_three_order_label = '1.3'

    pre_test
    test_information_displayed_is_subject_to_the_current_level_of_the_production_record_being_viewed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    create_mbr
    populate_the_accountability_page
  end

  def test_information_displayed_is_subject_to_the_current_level_of_the_production_record_being_viewed
    @mc.accountability.accountability_page_element.scroll_element_down 400
    verify_accountability_page_form_launch_table_for_unit_procedure_one
    verify_form_launch_on_operation_one
    verify_form_launch_on_operation_two
    verify_form_launch_on_operation_three
  end

  private

  def create_mbr
    operation_1_1 = OperationBuilder.new
                                    .with_title(@operation_one)
                                    .with_order_label('1.1')
                                    .with_order_number(1)
                                    .with_phase(PhaseFactory.phase_customizer
                                        .with_title('Phase 1')
                                        .with_order_label('1.1.1')
                                        .build)
                                    .build

    operation_1_2 = OperationBuilder.new
                                    .with_title(@operation_two)
                                    .with_order_label('1.2')
                                    .with_order_number(2)
                                    .with_phase(PhaseFactory.phase_customizer
                                        .with_title('Phase 2')
                                        .with_order_label('1.2.1')
                                        .build)
                                    .build

    operation_1_3 = OperationBuilder.new
                                    .with_title(@operation_three)
                                    .with_order_label('1.3')
                                    .with_order_number(3)
                                    .with_phase(PhaseFactory.phase_customizer
                                        .with_title('Phase 3')
                                        .with_order_label('1.3.1')
                                        .build)
                                    .build

    mbr_json = MasterBatchRecordBuilder.new
                                       .with_unit_procedure(
                                         UnitProcedureBuilder.new
                                             .with_operation(operation_1_1)
                                             .with_operation(operation_1_2)
                                             .with_operation(operation_1_3)
                                             .build
                                       )
                                       .build

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_master_batch_record_json(mbr_json)
                                                 .with_lot_number(@lot_number)
                                                 .with_connection(@connection)
                                                 .build

    lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @mc.ebr_navigation.go_to_first('operation', lot_number)
  end

  def populate_the_accountability_page
    launch_form_on_operation @operation_one_order_label, @form_one
    @mc.ebr_navigation.sidenav_navigate_to @operation_two_order_label
    launch_form_on_operation @operation_two_order_label, @form_two
    @mc.ebr_navigation.sidenav_navigate_to @operation_three_order_label
    launch_form_on_operation @operation_three_order_label, @form_three
    @mc.refresh
  end

  def launch_form_on_operation order_label, form
    @mc.accountability.launch_operation_form order_label
    @mc.batch_record_form_launch.select_form order_label, form: form
    @mc.batch_record_form_launch.launch phase_step: order_label
    assert @mc.accountability.form_was_launched?(order_label),
           form_not_launched_error(order_label)
  end

  def verify_accountability_page_form_launch_table_for_unit_procedure_one
    @mc.ebr_navigation.sidenav_navigate_to @unit_procedure_order_label
    assert @mc.accountability.launched_from_in_table?(@operation_one), could_not_find_error(@operation_one)
    assert @mc.accountability.launched_from_in_table?(@phase_one), could_not_find_error(@phase_one)
    assert @mc.accountability.launched_from_in_table?(@operation_two), could_not_find_error(@operation_two)
    assert @mc.accountability.launched_from_in_table?(@phase_two), could_not_find_error(@phase_two)
    assert @mc.accountability.launched_from_in_table?(@operation_three), could_not_find_error(@operation_three)
    assert @mc.accountability.launched_from_in_table?(@phase_three), could_not_find_error(@phase_three)
  end

  def verify_form_launch_on_operation_one
    @mc.ebr_navigation.sidenav_navigate_to @operation_one_order_label
    assert @mc.accountability.launched_from_in_table?(@operation_one), could_not_find_error(@operation_one)
    assert @mc.accountability.launched_from_in_table?(@phase_one), could_not_find_error(@phase_one)
  end

  def verify_form_launch_on_operation_two
    @mc.ebr_navigation.sidenav_navigate_to @operation_two_order_label
    assert @mc.accountability.launched_from_in_table?(@operation_two), could_not_find_error(@operation_two)
    assert @mc.accountability.launched_from_in_table?(@phase_two), could_not_find_error(@phase_two)
  end

  def verify_form_launch_on_operation_three
    @mc.ebr_navigation.sidenav_navigate_to @operation_three_order_label
    assert @mc.accountability.launched_from_in_table?(@operation_three), could_not_find_error(@operation_three)
    assert @mc.accountability.launched_from_in_table?(@phase_three), could_not_find_error(@phase_three)
  end

  def could_not_find_error item
    "Could not find ''#{item}'' in the Forms List"
  end

  def form_not_launched_error item
    "A form was not launched on #{item}"
  end
end
