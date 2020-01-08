# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq('S-08500_2_calculation_')
    @product_id = uniq('S-08500_2_id_')
    @lot_number = uniq('S-08500_2_lot_')
    @solution_one = '2'
    @solution_two = '3'
    @solution_three = '3'
    @solution_four = '5'
    @calculation_1_order_label = '1.1.1.3'
    @calculation_2_order_label = '1.1.1.4'
    @calculation_3_order_label = '1.1.1.5'
    @calculation_4_order_label = '1.1.2.2'
    @second_user = uniq('second_user_')

    pre_test
    test_calculations_will_complete_when_all_dependencies_are_complete
    test_user_who_completed_the_final_dependent_is_the_person_who_signs_off_the_calculation
    test_calculations_will_complete_when_output_from_observed_calculations_are_complete
  end

  def pre_test
    MCAPIs.create_user @second_user, roles: env['test_admin_role']
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    create_mbr_with_simple_addition_and_using_output_from_another_phase
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot_number
    @mc.ebr_navigation.go_to_first 'Phase', @lot_number
  end

  def test_calculations_will_complete_when_all_dependencies_are_complete
    @mc.phase.phase_steps[0].set_value '1'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[2].verify_expression @calculation_1_order_label, @solution_one
    @mc.phase.phase_steps[3].verify_expression @calculation_2_order_label, @solution_two
    @mc.phase.phase_steps[3].verify_expression @calculation_3_order_label, ''
  end

  def test_user_who_completed_the_final_dependent_is_the_person_who_signs_off_the_calculation
    @mc.batchrecord.verify_phase_step_sign_off @calculation_1_order_label, @admin
    @mc.batchrecord.verify_phase_step_sign_off @calculation_2_order_label, @admin
    @mc.log_out

    @mc.do.login @second_user, @admin_pass, approve_trainee: true
    @mc.ebr_navigation.go_to_first 'Phase', @lot_number
    @mc.phase.phase_steps[1].set_value '1'
    @mc.phase.phase_steps[1].blur
    @mc.phase.phase_steps[3].verify_expression @calculation_3_order_label, @solution_three
    @mc.batchrecord.verify_phase_step_sign_off @calculation_3_order_label, @second_user
  end

  def test_calculations_will_complete_when_output_from_observed_calculations_are_complete
    @mc.ebr_navigation.go_to_phase @lot_number, '2'
    @mc.phase.phase_steps[0].set_value '1'
    @mc.phase.phase_steps[0].blur
    @mc.phase.phase_steps[1].verify_expression @calculation_4_order_label, @solution_four
  end

  private

  def create_mbr_with_simple_addition_and_using_output_from_another_phase
    @mc.do.create_master_batch_record @master_template, @product_id, phase_count: 2, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.add_numeric

    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save

    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.add_data_step @calculation_1_order_label
    @mc.phase_step.calculation_step.save

    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.2'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.add_data_step @calculation_1_order_label
    @mc.phase_step.calculation_step.save

    @mc.phase_step.back
    @mc.structure_builder.phase_level.select_unit '2'
    @mc.structure_builder.phase_level.settings '2'
    @mc.structure_builder.phase_level.open_phase_builder '2'

    @mc.phase_step.add_numeric
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 2
    @mc.phase_step.calculation_step.add_data_step '1.1.1.5'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.choose_phase 3
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.add_data_step '1.1.2.1'
    @mc.phase_step.calculation_step.save

    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
  end
end
