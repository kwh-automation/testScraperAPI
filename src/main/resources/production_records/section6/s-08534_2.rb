# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('Lot')
    @prod_id = uniq('Product')

    pre_test
    test_launching_a_form_from_operation_one
    test_verifying_operation_two_has_been_unlocked
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true

    @mc.do.create_master_batch_record @prod_id, @prod_id, operation_count: 2, open_phase_builder: true, open_phase: '1'
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.structure_builder.operation_level.select_unit 2
    @mc.structure_builder.phase_level.add_unit set_name: 'Phase 1.2.1'
    @mc.structure_builder.phase_level.configure_phase 1
    sleep 5
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.structure_builder.operation_level.add_predecessor 2, 1
    @mc.do.publish_master_batch_record @prod_id, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_id}", @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
    assert !@mc.ebr_navigation.sidenav_link_is_active_structure_level?('Operation', 2)
  end

  def test_launching_a_form_from_operation_one
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    @mc.accountability.launch_operation_form '1.1'
    @mc.batch_record_form_launch.select_form '1.1'
    @mc.batch_record_form_launch.launch phase_step: '1.1'
    assert @mc.accountability.form_was_launched? '1.1'
    @mc.wait_for_video
  end

  def test_verifying_operation_two_has_been_unlocked
    @mc.ebr_navigation.sidenav_navigate_to '1.2.1'
    wait_until { @mc.ebr_navigation.header_text.include?('Phase 1.2.1') }
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
  end
end
