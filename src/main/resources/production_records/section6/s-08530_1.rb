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
    @connection = MCAPI.new
    @phase_one_order_label = '1.1.1'
    @not_applicable = 'No Longer Applicable'

    pre_test
    test_launching_a_form_from_the_phase
    test_verifying_phase_steps_are_marked_no_longer_applicable
    test_verifying_phase_completion_is_marked_as_no_longer_applicable
    test_launching_a_form_after_phase_completion
  end

  def pre_test
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@supervisor, @quality], connection: @connection
    @mc.do.login @admin, @admin_pass, approve_trainee: true

    @mc.do.create_batch_record @test_mbr, @lot_number

    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[0].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[0].witness.displayed_date != '' }
    @mc.phase.phase_steps[0].verification.autocomplete @supervisor
  end

  def test_launching_a_form_from_the_phase
    @mc.phase.phase_steps[0].launch_phase_form @phase_one_order_label
    @mc.batch_record_form_launch.select_form @phase_one_order_label
    @mc.batch_record_form_launch.launch phase_step: @phase_one_order_label

    @mc.batch_phase_step.launched_form @phase_one_order_label
    wait_until { @mc.ztest_form01.form_number? }
    assert @mc.ztest_form01.form_number?
    @mc.use_last_window
    assert @mc.phase.phase_steps[0].form_was_launched? @phase_one_order_label
  end

  def test_verifying_phase_steps_are_marked_no_longer_applicable
    assert @mc.phase.phase_steps[0].performed_by_info.include?(@not_applicable)
    assert @mc.phase.phase_steps[1].performed_by_info.include?(@not_applicable)
    assert @mc.phase.phase_steps[2].performed_by_info.include?(@not_applicable)
    @mc.wait_for_video
  end

  def test_verifying_phase_completion_is_marked_as_no_longer_applicable
    assert @mc.phase.completion.phase_no_longer_applicable?
  end

  def test_launching_a_form_after_phase_completion
    new_batch_for_form

    @mc.phase.completion.complete
    wait_until { @mc.phase.completion.date != '' }

    @mc.phase.phase_steps[0].launch_phase_form @phase_one_order_label
    @mc.batch_record_form_launch.select_form @phase_one_order_label
    @mc.batch_record_form_launch.launch phase_step: @phase_one_order_label

    @mc.batch_phase_step.launched_form @phase_one_order_label
    wait_until { @mc.ztest_form01.form_number? }
    assert @mc.ztest_form01.form_number?
    @mc.use_last_window
    assert @mc.phase.phase_steps[0].form_was_launched? @phase_one_order_label
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
