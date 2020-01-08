# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @pass = env['password']
    @quality = uniq('Quality_')
    @mbr_name = uniq('mt')
    @prod_id = uniq('prod')
    @lot_number = uniq('lot')
    @connection = MCAPI.new
    @phase = 'phase'
    @lot_amount = 15
    @instructions = 'To be cancelled for testing'
    @warning_label_displayed = 'This production record has been rejected and can no longer accept input.'
    @rejected = 'Rejected'
    @warning1 = 'Warning label did not display'
    @warning2 = 'Phase Step is not disabled'

    pre_test
    test_a_user_can_reject_a_production_record
    test_that_user_viewing_production_record_is_notified_of_rejection
    test_that_data_cannot_be_entered_after_rejection
  end

  def pre_test
    MCAPIs.create_user @quality, roles: env['test_admin_role'], connection: @connection
    @mc.do.login @admin, @admin_pass, connection: @connection, approve_trainee: true
    switch_browser_context @quality
    @mc.do.login @quality, @pass, connection: @connection, approve_trainee: true
    @mc.do.create_master_batch_record @mbr_name, @prod_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.add_instruction
    @mc.phase_step.instructions.add_instruction_text @instuctions
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @mbr_name, @prod_id
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record "#{@prod_id} #{@mbr_name}"
    @mc.batch_record_creation.lot_number = @lot_number
    @mc.batch_record_creation.lot_amount = @lot_amount
    @mc.batch_record_creation.create
    @mc.ebr_navigation.go_to_first @phase, @lot_number
    switch_browser_context @admin
    @mc.ebr_navigation.go_to_first @phase, @lot_number
    @mc.phase.phase_steps[0].autocomplete
  end

  def test_a_user_can_reject_a_production_record
    switch_browser_context @quality
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.emergency_reject_batch_record @admin
  end

  def test_that_user_viewing_production_record_is_notified_of_rejection
    switch_browser_context @admin
    assert @mc.warning.displayed(with_text: @warning_label_displayed), @warning1
    switch_browser_context @quality
    @mc.go_to.ebr
    @mc.ebr.view_all_batch_records
    @mc.batch_record_list.filter_by :lot_number, @lot_number
    wait_until { @mc.batch_record_list.get_status_data(0).include? @rejected }
  end

  def test_that_data_cannot_be_entered_after_rejection
    switch_browser_context @admin
    assert @mc.phase.phase_steps[1].disabled?, @warning2
  end
end
