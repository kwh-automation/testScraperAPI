# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @mbr = uniq('corrections_')
    @id = uniq('id_')
    @lot = uniq('lot_')
    @admin = env['admin_user']
    @admin_pass = env['password']
    @connection = MCAPI.new

    pre_test
    test_a_correction_can_be_performed_after_a_phase_is_complete
    test_a_qa_form_can_be_launched_after_a_phase_is_complete
  end

  def pre_test
    create_mbr
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.go_to.ebr
    @mc.ebr_navigation.go_to_first('phase', @lot)
    @mc.batch_phase_step.start_new_iteration
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
  end

  def test_a_correction_can_be_performed_after_a_phase_is_complete
    @mc.phase.completion.complete
    @mc.iterating_phase_table_view.click_data_table_iteration 1
    @mc.phase.phase_steps[0].start_correction
    wait_until { @mc.phase.phase_steps[0].correction.submit_correction_element.visible? }
    @mc.phase.phase_steps[0].set_text 'goodbye'
    @mc.phase.phase_steps[0].correction.submit_correction
    wait_until { @mc.phase.phase_steps[0].correction.date != '' }
    @mc.phase.phase_steps[0].correction.finish_correction
  end

  def test_a_qa_form_can_be_launched_after_a_phase_is_complete
    @mc.phase.phase_steps[0].launch_phase_form '1.1.1'
    @mc.batch_record_form_launch.select_form '1.1.1'
    @mc.batch_record_form_launch.launch phase_step: '1.1.1'

    @mc.batch_phase_step.launched_form '1.1.1'
    wait_until { @mc.ztest_form01.form_number? }
    assert @mc.ztest_form01.form_number?
    @mc.use_last_window
    assert @mc.phase.phase_steps[0].form_was_launched? '1.1.1'
  end

  private

  def create_mbr
    phase = PhaseFactory.phase_customizer
                        .with_title('Phase 1')
                        .with_order_label('1.1.1')
                        .with_order_number(1)
                        .with_phase_step(GeneralTextBuilder.new
                                            .with_order_label('1.1.1.1')
                                            .with_order_number(1)
                                            .with_minimum_length(1)
                                            .with_maximum_length(120)
                                            .with_correction_configuration(CorrectionConfigurationBuilder.new.build)
                                            .with_notes
                                            .build)
                        .with_iterate_by(1)
                        .build

    operation = OperationBuilder.new
                                .with_title('Operation 1')
                                .with_order_label('1.1')
                                .with_order_number(1)
                                .with_phase(phase)
                                .build

    procedure = UnitProcedureBuilder.new
                                    .with_order_number(1)
                                    .with_order_label('1')
                                    .with_title('Unit procedure 1')
                                    .with_operation(operation)
                                    .build

    mbr_json = MasterBatchRecordBuilder.new
                                       .with_unit_procedure(procedure)
                                       .with_product_id(@id)
                                       .with_product_name(@mbr)
                                       .with_release_role_id('00000000000FTADMIN')
                                       .with_revision_number('A')
                                       .build

    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_master_batch_record_json(mbr_json)
                                                 .with_lot_number(@lot)
                                                 .with_connection(@connection)
                                                 .build

    @lot = "#{@lot}_1"
  end
end
