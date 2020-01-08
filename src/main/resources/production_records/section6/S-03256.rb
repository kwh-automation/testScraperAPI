# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @connection = MCAPI.new
    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_connection(@connection)
                                                 .with_unit_procedure_count(2)
                                                 .with_operation_count(2)
                                                 .with_phase_count(3)
                                                 .build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number

    pre_test
    test_percent_complete_gauge_shows_the_progress_of_the_production_record
    test_percent_complete_gauge_is_subject_to_the_current_level_of_the_production_record_being_viewed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    execute_on_production_record
  end

  def test_percent_complete_gauge_shows_the_progress_of_the_production_record
    @mc.ebr_navigation.go_to_procedure_level
    assert @mc.accountability.percentage_complete == '50%', 'Progress does not show 50%'
    @mc.wait_for_video time: 2
  end

  def test_percent_complete_gauge_is_subject_to_the_current_level_of_the_production_record_being_viewed
    @mc.ebr_navigation.sidenav_navigate_to '1'
    assert @mc.accountability.percentage_complete == '83%', 'Progress does not show 83%'
    @mc.wait_for_video time: 2
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    assert @mc.accountability.percentage_complete == '100%', 'Progress does not show 100%'
    @mc.wait_for_video time: 2
    @mc.ebr_navigation.sidenav_navigate_to '1.2'
    assert @mc.accountability.percentage_complete == '66%', 'Progress does not show 66%'
    @mc.wait_for_video time: 2
    @mc.ebr_navigation.sidenav_navigate_to '2'
    assert @mc.accountability.percentage_complete == '16%', 'Progress does not show 16%'
    @mc.wait_for_video time: 2
    @mc.ebr_navigation.sidenav_navigate_to '2.1'
    assert @mc.accountability.percentage_complete == '33%', 'Progress does not show 33%'
    @mc.wait_for_video time: 2
    @mc.ebr_navigation.sidenav_navigate_to '2.2'
    assert @mc.accountability.percentage_complete == '0%', 'Progress does not show 0%'
    @mc.wait_for_video time: 2
  end

  private

  def execute_on_production_record
    @mc.ebr_navigation.go_to_phase @lot_number, 1
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.completion.complete
    @mc.ebr_navigation.sidenav_navigate_to '1.1.2'
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.completion.complete
    @mc.ebr_navigation.sidenav_navigate_to '1.1.3'
    @mc.phase.phase_steps[0].autocomplete
    @mc.ebr_navigation.sidenav_navigate_to '1.2.1'
    @mc.phase.phase_steps[0].autocomplete
    @mc.ebr_navigation.sidenav_navigate_to '1.2.2'
    @mc.phase.phase_steps[0].autocomplete
    @mc.ebr_navigation.sidenav_navigate_to '2.1.1'
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.completion.complete
  end
end
