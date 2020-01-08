# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @quality = uniq('Quality_')
    @supervisor = uniq('Super_')
    @unit_procedure_one_order_label = '1'
    @connection = MCAPI.new

    pre_test
    test_launching_a_form_from_the_unit
    test_verifying_phase_and_phase_steps_are_marked_no_longer_applicable
    test_verifying_operation_is_no_longer_app
  end

  def pre_test
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: @connection
    MCAPIs.create_user @supervisor, roles: env['test_admin_role'], connection: @connection
    MCAPIs.approve_trainees [@supervisor, @quality], connection: @connection

    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @lot_number = uniq('Lot')
    @prod_id = uniq('1', false)
    @prod_name = uniq('s08630_', false)

    @mc.do.create_master_batch_record_with_signoffs @prod_name, @prod_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_witness
    @mc.phase_step.general_text.enable_verification
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @prod_name, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_name}", @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[0].witness.autocomplete @quality
    wait_until { @mc.phase.phase_steps[0].witness.displayed_date != '' }
    @mc.phase.phase_steps[0].verification.autocomplete @supervisor
  end

  def test_launching_a_form_from_the_unit
    @mc.ebr_navigation.sidenav_navigate_to @unit_procedure_one_order_label
    @mc.accountability.launch_operation_form @unit_procedure_one_order_label
    @mc.batch_record_form_launch.select_form @unit_procedure_one_order_label
    @mc.batch_record_form_launch.launch phase_step: @unit_procedure_one_order_label

    @mc.accountability.launched_form @unit_procedure_one_order_label
    assert @mc.ztest_form01.form_number?
    @mc.wait_for_video
    @mc.use_last_window
    assert @mc.accountability.form_was_launched? @unit_procedure_one_order_label
  end

  def test_verifying_phase_and_phase_steps_are_marked_no_longer_applicable
    @mc.ebr_navigation.go_to_first('Phase', @lot_number)
    assert @mc.phase.phase_steps[0].performed_by_info.include?('No Longer Applicable')
    assert @mc.phase.phase_steps[0].witness.performer? @quality
    assert @mc.phase.phase_steps[0].verification.performer? @supervisor
    assert @mc.phase.completion.phase_no_longer_applicable?
  end

  def test_verifying_operation_is_no_longer_app
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    assert !@mc.accountability.open_menu_element.exists?
    assert @mc.accountability.first_sign_off_not_applicable_element.exists?
  end

  def test_launching_a_form_on_completed_phase
    new_batch_for_form

    @mc.phase.completion.complete
    wait_until { @mc.phase.completion.date != '' }

    @mc.ebr_navigation.sidenav_navigate_to @unit_procedure_one_order_label
    @mc.accountability.launch_operation_form @unit_procedure_one_order_label
    @mc.batch_record_form_launch.select_form @unit_procedure_one_order_label
    @mc.batch_record_form_launch.launch phase_step: @unit_procedure_one_order_label

    @mc.accountability.launched_form @unit_procedure_one_order_label
    assert @mc.ztest_form01.form_number?
    @mc.wait_for_video
    @mc.use_last_window
    assert @mc.accountability.form_was_launched? @unit_procedure_one_order_label
  end

  private

  def new_batch_for_form
    @mc.do.create_batch_record @test_mbr, @lot_number_2
    @mc.ebr_navigation.go_to_first('phase', @lot_number_2)
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
