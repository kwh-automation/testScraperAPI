# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('depend')
    @prod_id = uniq('depends')

    pre_test
    test_navigating_to_the_active_phase
    test_entering_data_into_phase_steps_of_active_phase
    test_if_the_second_phase_enable_once_first_phase_is_completed
    test_navigating_to_completed_phase
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @prod_id, @prod_id, phase_count: 2, open_phase_builder: true, open_phase: '1'
    @mc.phase_step.add_general_text
    @mc.phase_step.add_general_text
    wait_until { @mc.phase_step.back_element.visible? }
    @mc.phase_step.back
    @mc.structure_builder.phase_level.configure_phase 2
    @mc.phase_step.add_general_text
    wait_until { @mc.phase_step.back_element.visible? }
    @mc.phase_step.back
    @mc.structure_builder.phase_level.add_predecessor 2, 1
    @mc.do.publish_master_batch_record @prod_id, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_id}", @lot_number
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_number
  end

  def test_navigating_to_the_active_phase
    @mc.ebr_navigation.sidenav_navigate_to '1.1.2'
    assert @mc.phase.phase_steps[0].disabled?
    assert @mc.ebr_navigation.on_phase_page?
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
    assert @mc.ebr_navigation.sidenav_link_is_active_structure_level? 'Phase', 1
    assert !@mc.ebr_navigation.sidenav_link_is_active_structure_level?('Phase', 2)
  end

  def test_entering_data_into_phase_steps_of_active_phase
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.phase_steps[1].autocomplete
    wait_until { !@mc.phase.phase_steps[1].date.nil? }
    assert @mc.phase.phase_steps[0].performer? @admin
  end

  def test_if_the_second_phase_enable_once_first_phase_is_completed
    @mc.phase.completion.complete
    @mc.ebr_navigation.sidenav_navigate_to '1.1.2'
    wait_until { @mc.ebr_navigation.header_text.include?('Phase 2') }
    assert !@mc.phase.phase_steps[0].disabled?
  end

  def test_navigating_to_completed_phase
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
    object = nil
    count = 0
    while object.nil? && count != 3
      begin
        unless @mc.phase.phase_steps[0].performer.empty?
          object = @mc.phase.phase_steps[0].performer
          assert @mc.phase.phase_steps[0].performer? @admin
        end
      rescue Selenium::WebDriver::Error::StaleElementReferenceError
        puts 'Caught: Stale Element Reference Error'
        count += 1
      end
    end
  end
end
