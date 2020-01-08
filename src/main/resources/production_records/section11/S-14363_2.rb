require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq('pass_fail_')
    @mbr_id = uniq('actions_on_')
    @lot = uniq('test_action_')

    pre_test
    test_repeat_operation_is_triggered_when_outside_of_configured_limit
  end

  def pre_test
    @connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    create_br_with_pass_fail_limit
    @mc.go_to.ebr
    @mc.ebr_navigation.go_to_lot @lot
    @mc.ebr_navigation.sidenav_navigate_to "1.1(1).1"
  end

  def test_repeat_operation_is_triggered_when_outside_of_configured_limit
    @mc.phase.phase_steps[0].select_fail
    @mc.ebr_navigation.sidenav_navigate_to "1.1(2).1"
    @mc.phase.phase_steps[0].select_pass
  end

  private

  def create_br_with_pass_fail_limit
    phase = PhaseFactory.phase_customizer()
                .with_title('Phase 1')
                .with_order_label('1.1.1')
                .with_order_number(1)
                .with_phase_step(PassFailBuilder.new
                                    .with_order_label('1.1.1.1')
                                    .with_limit(GeneralNumericLimitBuilder.new
                                                    .with_label('Repeat Operation if not: ')
                                                    .with_minimum_value(1)
                                                    .with_maximum_value(1)
                                                    .with_visibility(true)
                                                    .with_action('REPEAT_OPERATION')
                                                    .build)
                                    .build)
                .build

    operation = OperationBuilder.new
                    .with_repetition
                    .with_title("Repeatable")
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
                            .with_lot_number(@lot)
                            .build

    @lot = @lot + "_1"

  end

end