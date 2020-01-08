# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @quality = uniq('Quality_')
    @supervisor = uniq('Super_')
    @lot_number = uniq('')
    @lot_number_two = uniq('2_')
    @test_mbr = "#{env['mbr_product_id']} #{env['mbr_product_name']}"
    @phase_one_order_label = '1.1.1.1'

    pre_test
    test_form_was_launched
    test_data_capture_is_overridden_with_launched_form
    test_data_capture_no_longer_applicable
    test_witness_is_still_shown
    test_verify_is_still_shown
    test_form_can_be_launched_after_phase_completion
  end

  def pre_test
    connection = MCAPI.new
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: connection
    MCAPIs.approve_trainees [@quality, @supervisor], connection: connection
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection

    @mc.do.enable_process_workflow 'ztest-form01'

    @mc.do.create_batch_record @test_mbr, @lot_number

    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[0].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[0].witness.displayed_date != '' }
    @mc.phase.phase_steps[0].verification.autocomplete @supervisor

    @mc.batch_phase_step.launch_phase_form @phase_one_order_label
    @mc.batch_record_form_launch.select_form @phase_one_order_label
    @mc.batch_record_form_launch.launch

    @mc.batch_phase_step.launched_form @phase_one_order_label
    sleep 1
  end

  def test_form_was_launched
    assert @mc.ztest_form01.form_number?
    @mc.use_last_window
  end

  def test_data_capture_is_overridden_with_launched_form
    @mc.phase.phase_steps[0]
    assert @mc.phase.phase_steps[0].form_was_launched? @phase_one_order_label
  end

  def test_data_capture_no_longer_applicable
    assert @mc.batchrecord.is_phase_step_no_longer_applicable? @phase_one_order_label
  end

  def test_witness_is_still_shown
    assert @mc.phase.phase_steps[0].witness.performer? @quality
  end

  def test_verify_is_still_shown
    assert @mc.phase.phase_steps[0].verification.performer? @supervisor
  end

  def test_form_can_be_launched_after_phase_completion
    new_batch_for_form

    @mc.phase.completion.complete
    wait_until { @mc.phase.completion.date != '' }

    @mc.batch_phase_step.launch_phase_form @phase_one_order_label
    @mc.batch_record_form_launch.select_form @phase_one_order_label
    @mc.batch_record_form_launch.launch

    @mc.batch_phase_step.launched_form @phase_one_order_label
    sleep 1

    assert @mc.ztest_form01.form_number?
  end

  private

  def new_batch_for_form
    @mc.do.create_batch_record @test_mbr, @lot_number_two
    @mc.ebr_navigation.go_to_first('phase', @lot_number_two)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[0].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[0].witness.displayed_date != '' }
    @mc.phase.phase_steps[0].verification.autocomplete @supervisor
    @mc.phase.phase_steps[1].set_value '123'
    @mc.phase.phase_steps[1].blur
    @mc.phase.phase_steps[1].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[1].witness.displayed_date != '' }
    @mc.phase.phase_steps[1].verification.autocomplete @supervisor
    @mc.phase.phase_steps[2].select_option 1
    wait_until { @mc.phase.phase_steps[2].date != '' }
    @mc.phase.phase_steps[2].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[2].witness.displayed_date != '' }
    @mc.phase.phase_steps[2].verification.autocomplete @supervisor
  end
end
