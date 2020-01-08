require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('calculation_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')

    pre_test
    test_adding_a_calculation_output_and_a_static_number
    test_adding_a_calculation_output_and_a_numeric_data_type
    test_adding_a_numeric_data_type_from_another_phase
    test_adding_a_calculation_data_type_from_another_phase
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_numeric
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_calculation_output_and_a_static_number
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.2'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_calculation_output_and_a_numeric_data_type
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step '1.1.1.2'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_numeric_data_type_from_another_phase
    @mc.phase_step.back
    @mc.structure_builder.phase_level.add_unit set_name: "Phase 2"
    @mc.structure_builder.phase_level.select_unit "2"
    @mc.structure_builder.phase_level.settings "2"
    @mc.structure_builder.phase_level.open_phase_builder "2"
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 2
    @mc.phase_step.calculation_step.add_data_step '1.1.1.1'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

  def test_adding_a_calculation_data_type_from_another_phase
    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.choose_phase 2
    @mc.phase_step.calculation_step.add_data_step '1.1.1.2'
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
  end

end
