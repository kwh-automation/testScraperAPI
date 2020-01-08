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
    test_launching_a_form_from_phase_one
    test_verifying_phase_two_has_been_unlocked
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @prod_id, @prod_id, phase_count: 2, open_phase_builder: true, open_phase: '1'
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.structure_builder.phase_level.configure_phase 2
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.structure_builder.phase_level.add_predecessor 2, 1
    @mc.do.publish_master_batch_record @prod_id, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_id}", @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    assert !@mc.ebr_navigation.sidenav_link_is_active_structure_level?('Phase', 2)
  end

  def test_launching_a_form_from_phase_one
    @mc.phase.phase_steps[0].launch_phase_form '1.1.1'
    @mc.batch_record_form_launch.select_form '1.1.1'
    @mc.batch_record_form_launch.launch phase_step: '1.1.1'

    @mc.batch_phase_step.launched_form '1.1.1'
    assert @mc.ztest_form01.form_number?
    @mc.use_last_window
    assert @mc.phase.phase_steps[0].form_was_launched? '1.1.1'
  end

  def test_verifying_phase_two_has_been_unlocked
    @mc.ebr_navigation.sidenav_navigate_to '1.1.2'
    wait_until { @mc.ebr_navigation.header_text.include?('Phase 2') }
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
  end
end
