# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @esig = env['admin_esig']
    @password = env['password']
    @worker = uniq('worker_')
    @master_template = uniq('master_template_')
    @product_id = uniq('product_id_')
    @lot_number = uniq('lot_number_')

    pre_test
    test_calculations_with_only_global_variables_dependents_are_preformed_by_the_user_who_launched_the_production_record
  end

  def pre_test
    connection = MCAPI.new
    MCAPIs.create_user @worker, roles: env['test_admin_role'], connection: connection
    MCAPIs.approve_trainees [@admin, @worker]

    @mc.do.login @admin, @password
    create_master_template
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number
    @mc.log_out

    @mc.do.login @worker, @password
    @mc.ebr_navigation.go_to_first 'Phase', @lot_number
  end

  def test_calculations_with_only_global_variables_dependents_are_preformed_by_the_user_who_launched_the_production_record
    @mc.phase.phase_steps[0].set_text '1'
    @mc.phase.phase_steps[0].blur
    @mc.batchrecord.verify_phase_step_sign_off '1.1.1.1', @worker
    @mc.batchrecord.verify_phase_step_sign_off '1.1.1.2', @admin
  end

  private

  def create_master_template
    @mc.do.create_master_batch_record @master_template, @product_id, phase_count: 1, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 1
    @mc.phase_step.calculation_step.add_data_step '#'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
  end
end
