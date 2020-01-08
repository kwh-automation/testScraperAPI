require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]


    pre_test
    test_enabling_supervisor_override
    test_supervisor_override_disables_limit_validation
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection

    mbr_json =
      PhaseFactory.phase_customizer
                  .with_phase_step(
                    GeneralNumericBuilder.new
                      .with_limit(
                        GeneralNumericLimitBuilder.new
                          .with_label('Physical')
                          .with_minimum_value(0)
                          .with_maximum_value(10)
                          .with_visibility(true)
                          .with_action('REJECT')
                          .build
                      )
                      .with_limit(
                        GeneralNumericLimitBuilder.new
                          .with_label('Shown limit')
                          .with_minimum_value(2)
                          .with_maximum_value(8)
                          .with_visibility(true)
                          .with_action('WARN')
                          .build
                      )
                  )
                  .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(mbr_json).build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
  end

  def test_enabling_supervisor_override
    @mc.phase.phase_steps[0].toggle_supervisor_override
    assert @mc.phase.phase_steps[0].supervisor_override_enabled?
  end

  def test_supervisor_override_disables_limit_validation
    @mc.phase.phase_steps[0].set_value '100'
    @mc.phase.phase_steps[0].blur
    assert @mc.phase.phase_steps[0].captured_value == '100'
  end
end
