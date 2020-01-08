require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_label_displays_next_to_data_entry_field
    test_label_displays_next_to_data_in_table_view
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection

    @unit_of_measure = "kg"
    custom_phase_with_unit_of_measure =
        PhaseFactory.phase_customizer()
        .with_phase_step(GeneralNumericBuilder.new.with_unit_of_measure(@unit_of_measure))
        .with_iterate_by(1)
        .build_single_level_master_batch_record

    @test_environment =
        EbrTestEnvironmentBuilder.new
        .with_connection(connection)
        .with_lot_number(uniq("S-03910"))
        .with_product_id(uniq("S-03910"))
        .with_master_batch_record_json(custom_phase_with_unit_of_measure)
        .build

    @product_id = @test_environment.master_batch_records[0].product_id
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end

  def test_label_displays_next_to_data_entry_field
    @mc.ebr_navigation.go_to_first "phase", @lot_number
    @mc.batch_phase_step.start_new_iteration
    general_numeric = @mc.phase.phase_steps[0]

    assert general_numeric.unit_of_measure == @unit_of_measure
    general_numeric.autocomplete
    assert general_numeric.unit_of_measure == @unit_of_measure
    @mc.phase.completion.complete
  end

  def test_label_displays_next_to_data_in_table_view
    @mc.batch_phase_step.table_view

    table_data = @mc.iterating_phase_table_view.get_data_capture_value_by_iteration 1
    assert table_data.include? @unit_of_measure
  end

end