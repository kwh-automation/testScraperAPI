# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @text_value = '12345'
    @quality_user = uniq('quality_')
    @quality_pass = env['password']

    pre_test

    test_viewing_activity_log
    test_that_activity_log_has_appropriate_fields
    test_that_activity_log_information_is_subject_to_current_production_record_level
    test_navigating_to_phase_step_via_link_in_activity_log
  end

  def pre_test
    connection = MCAPI.new
    @test_environment = EbrTestEnvironmentBuilder.new
                                                 .with_batch_records_per_master_batch_record(1)
                                                 .with_operation_count(2)
                                                 .with_unit_procedure_count(2)
                                                 .with_phase_steps_count(2)
                                                 .with_phase_count(2)
                                                 .with_connection(connection)
                                                 .build

    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection
    MCAPIs.create_user @quality_user, roles: env['test_admin_role'], connection: connection
    MCAPIs.approve_trainees [@quality_user], esig: env['admin_esig'], connection: connection
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end

  def test_viewing_activity_log
    @mc.ebr_navigation.go_to_first 'Unit Procedure', @lot_number
    @mc.ebr_navigation.go_to_activity_log
  end

  def test_that_activity_log_has_appropriate_fields
    @headers = @mc.batchrecordactivitylog.activity_log_list_table_headers
    assert @headers.include? 'user id'
    assert @headers.include? 'full name'
    assert @headers.include? 'date &amp; time'
    assert @headers.include? 'field id / name'
    assert @headers.include? 'action taken'
    assert @headers.include? 'value entered'
    completing_phase_updates_activity_log_for_other_users
  end

  def test_that_activity_log_information_is_subject_to_current_production_record_level
    switch_browser_context(@admin)
    @mc.ebr_navigation.go_to_activity_log
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    @mc.ebr_navigation.activity_log
    assert !@mc.batchrecordactivitylog.activity_log_list_table.empty?,
           'The Operation activity log is empty, but it should not be.'
    @mc.ebr_navigation.sidenav_navigate_to '2'
    @mc.ebr_navigation.activity_log
    assert @mc.batchrecordactivitylog.activity_log_list_table.empty?,
           'The Unit-Procedure activity log is not empty, but it should be.'
    @mc.ebr_navigation.go_to_activity_log
    @mc.ebr_navigation.sidenav_navigate_to '1'
    @mc.ebr_navigation.activity_log
    assert @mc.batchrecordactivitylog.activity_log_list_table[0][@headers.index('value entered')] == @text_value,
           'The value entered is not displaying the correct information.'
  end

  def test_navigating_to_phase_step_via_link_in_activity_log
    @mc.batchrecordactivitylog.click_on_id_and_name_link 1
    wait_until { @mc.ebr_navigation.header_text.include? '1.1.1 - Phase 1' }
  end

  private

  def completing_phase_updates_activity_log_for_other_users
    @mc.ebr_navigation.go_to_first 'phase', @lot_number
    @mc.phase.phase_steps[0].set_text @text_value
    @mc.phase.phase_steps[0].blur

    switch_browser_context(@quality_user)
    @mc.do.login @quality_user, @quality_pass
    @mc.ebr_navigation.go_to_first 'Unit Procedure', @lot_number
    @mc.ebr_navigation.activity_log
    wait_until { !@mc.batchrecordactivitylog.activity_log_list_table.empty? }
    activity_log_is_updated_for_other_user =
      @mc.batchrecordactivitylog.activity_log_list_table[0][@headers.index('value entered')] == @text_value
    assert activity_log_is_updated_for_other_user, 'Activity Log did not update for other users.'
  end
end
