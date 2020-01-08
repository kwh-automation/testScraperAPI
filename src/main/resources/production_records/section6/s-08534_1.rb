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
    @test_mbr = "#{env['mbr_product_id']} #{env['mbr_product_name']}"
    @connection = MCAPI.new
    @operation_one_order_label = '1.1'

    pre_test
    test_launching_a_form_from_the_operation
    test_verifying_phase_completion_is_marked_as_no_longer_applicable
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

  def test_launching_a_form_from_the_operation
    @mc.ebr_navigation.sidenav_navigate_to @operation_one_order_label
    @mc.accountability.launch_operation_form @operation_one_order_label
    @mc.batch_record_form_launch.select_form @operation_one_order_label
    @mc.batch_record_form_launch.launch phase_step: @operation_one_order_label

    @mc.accountability.launched_form @operation_one_order_label
    wait_until(5) { @mc.ztest_form01.form_number? }
    assert @mc.ztest_form01.page_one.mastercontrol_form_number?
    @mc.wait_for_video
    @mc.use_last_window
    assert @mc.accountability.form_was_launched? @operation_one_order_label
  end

  def test_verifying_phase_completion_is_marked_as_no_longer_applicable
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
    assert @mc.phase.completion.phase_no_longer_applicable?
  end
end
