require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @lot_number = uniq("loop_op_")
    @op_title = uniq("oper_")
    @val_1 = "123"
    @val_2 = "456"
    @connection = MCAPI.new

    pre_test
    test_adding_a_repeated_operation
    test_repeated_operation_appears_in_side_nav
    test_users_can_complete_data_captures_on_repeated_operations
    test_data_captures_on_new_iterations_do_not_affect_data_captures_on_previous_iterations
    test_repeated_operation_event_is_shown_in_activity_log
  end

  def pre_test
    @mc.do.login @admin, @admin_pass
    MCAPIs.approve_trainees [@admin], connection: @connection
    create_test_template
    @mc.ebr_navigation.go_to_lot @lot_number
    @mc.ebr_navigation.sidenav_navigate_to "1.1(1).1"
    @mc.phase.phase_steps[0].autocomplete value:@val_1
  end

  def test_adding_a_repeated_operation
    @mc.ebr_navigation.sidenav_navigate_to "1.1(1)"
    wait_until { @mc.accountability.percent_complete_element.visible? }
    @mc.accountability.repeat_operation "1"
    assert ( @mc.success.displayed with_text: "The operation you are in has just repeated" )
    @mc.refresh
  end

  def test_repeated_operation_appears_in_side_nav
    @mc.ebr_navigation.sidenav_navigate_to  "1.1(2)"
    wait_until { @mc.accountability.percent_complete_element.visible? }
    assert ( @mc.accountability.header_text_element.text.include? "1.1(2)" )
  end

  def test_users_can_complete_data_captures_on_repeated_operations
    @mc.ebr_navigation.sidenav_navigate_to "1.1(2).1"
    @mc.phase.phase_steps[0].autocomplete value:@val_2
    assert ( @mc.phase.phase_steps[0].performer? @admin )
    assert ( @mc.phase.phase_steps[0].captured_value.include? @val_2 )
  end

  def test_data_captures_on_new_iterations_do_not_affect_data_captures_on_previous_iterations
    @mc.ebr_navigation.sidenav_navigate_to "1.1(1).1"
    assert ( @mc.phase.phase_steps[0].captured_value.include? @val_1 )
  end

  def test_repeated_operation_event_is_shown_in_activity_log
    @mc.ebr_navigation.sidenav_navigate_to "1.1(1)"
    wait_until { @mc.accountability.percent_complete_element.visible? }
    @mc.ebr_navigation.activity_log_element.click
    headers = @mc.batchrecordactivitylog.activity_log_list_table_headers
    assert (@mc.batchrecordactivitylog.activity_log_list_table[0][headers.index("action taken")] == "Data Entry")
    @mc.ebr_navigation.sidenav_navigate_to "1.1(2)"
    wait_until { @mc.accountability.percent_complete_element.visible? }
    @mc.ebr_navigation.activity_log_element.click
    assert (@mc.batchrecordactivitylog.activity_log_list_table[0][headers.index("action taken")] == "Structure Repeated")
  end

  private

  def create_test_template
    phase = PhaseFactory.new
                .with_order_label("1.1.1")
                .with_phase_step(GeneralNumericBuilder.new
                                     .with_order_label("1.1.1.1")
                                     .with_title("Number")
                                     .build)
                .with_phase_step(DateTimeBuilder.new
                                     .with_title("Now")
                                     .with_order_label("1.1.1.2")
                                     .with_order_number(2)
                                     .build)
                .build

    operation = OperationBuilder.new
                    .with_repetition
                    .with_title(@op_title)
                    .with_order_label("1.1")
                    .with_phase(phase)
                    .build

    mt_json = MasterBatchRecordBuilder.new
                   .with_unit_procedure(UnitProcedureBuilder.new
                                            .with_order_label("1")
                                            .with_operation(operation)
                                            .build)
                   .with_product_id(@id)
                   .with_product_name(@mbr)
                   .with_release_role_id('00000000000FTADMIN')
                   .with_revision_number('A')
                   .build

    @test_environment = EbrTestEnvironmentBuilder.new
                            .with_master_batch_record_json(mt_json)
                            .with_lot_number(@lot_number)
                            .with_connection(@connection)
                            .build

    @lot_number = @lot_number + "_1"
  end

end