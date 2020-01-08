require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("aql_duplication")
    @product_id = uniq("aql_duplication", false)
    @lot_number = uniq("lot_", true)
    @release_role_id = '00000000000FTADMIN'
    @group = ["Chunky Pills", "Juicy Pills"]
    @severity = ["ZERO_TOLERANCE", "CRITICAL", "MAJOR", "MINOR"]

    @connection = MCAPI.new

    pre_test
    test_configuration_of_inspection_plan_is_copied_to_new_revisions_or_duplicates_of_the_master_template
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    create_master_template
    @mc.go_to.ebr
    @mc.go_to.ebr.inspections
    @mc.inspections.filter_by :master_template, @mbr_name
    @mc.inspections.open_master_template @mbr_name
    wait_until { @mc.manage_inspections.severity_element.visible? }
    @mc.manage_inspections.select_existing_range 1

    @mc.manage_inspections.severity_level "Minor", row: 1
    @mc.manage_inspections.severity_level "Major", row: 2
    @mc.manage_inspections.severity_level "Minor", row: 3
    @mc.manage_inspections.severity_level "Major", row: 4

    @mc.manage_inspections.add_reject_count 2, row: 1
    @mc.manage_inspections.add_reject_count 3, row: 2
    @mc.manage_inspections.add_reject_count 4, row: 3
    @mc.manage_inspections.add_reject_count 5, row: 4

    @mc.manage_inspections.add_range

    @mc.manage_inspections.add_reject_count 6, row: 1
    @mc.manage_inspections.add_reject_count 7, row: 2
    @mc.manage_inspections.add_reject_count 8, row: 3
    @mc.manage_inspections.add_reject_count 9, row: 4

    @mc.manage_inspections.add_group @group[0]
    @mc.manage_inspections.assign_phase_steps
    @mc.assign_phase_steps.step 3
    @mc.assign_phase_steps.step 4
    @mc.assign_phase_steps.assign
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[2], 50
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[3], 50

    @mc.manage_inspections.select_existing_range 1

    @mc.manage_inspections.group_reject_threshold @group[0], @severity[2], 50
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[3], 50
  end

  def test_configuration_of_inspection_plan_is_copied_to_new_revisions_or_duplicates_of_the_master_template
    @mc.go_to.ebr
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.duplicate_mbr @product_id

    @mc.go_to.ebr
    @mc.go_to.ebr.inspections
    @mc.inspections.filter_by :product_id, @product_id + "-DUPLICATE"
    @mc.inspections.open_master_template @mbr_name
    @mc.manage_inspections.select_existing_range 1

    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.1", check_value: 2
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.2", check_value: 3
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.3", check_value: 4
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.4", check_value: 5

    @mc.manage_inspections.select_existing_range 2

    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.1", check_value: 6
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.2", check_value: 7
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.3", check_value: 8
    assert @mc.manage_inspections.check_reject_count step_id: "1.1.1.4", check_value: 9
  end

  private
  def create_master_template
    puts 'Creating Master Template with pass/fail data type...'

    phase_1 = PhaseFactory.phase_customizer()
                        .with_title('Phase 1')
                        .with_order_label('1.1.1')
                        .with_order_number(1)
                        .with_phase_step(PassFailBuilder.new
                                                        .with_order_label('1.1.1.1')
                                                        .with_aql_inspection_plan
                                                        .build)
                        .with_phase_step(PassFailBuilder.new
                                                        .with_order_label('1.1.1.2')
                                                        .with_aql_inspection_plan
                                                        .build)
                        .with_phase_step(PassFailBuilder.new
                                                        .with_order_label('1.1.1.3')
                                                        .with_aql_inspection_plan
                                                        .build)
                        .with_phase_step(PassFailBuilder.new
                                                        .with_order_label('1.1.1.4')
                                                        .with_aql_inspection_plan
                                                        .build)
                        .build

    mbr_json = MasterBatchRecordBuilder.new
                                       .with_unit_procedure(UnitProcedureBuilder.new
                                       .with_operation(OperationBuilder.new
                                       .with_phase(phase_1).build).build)
                                       .with_product_id(@product_id)
                                       .with_product_name(@mbr_name)
                                       .with_release_role_id(@release_role_id)
                                       .build

    puts "Finished creating Master Template as #{@product_id}"

    @test_environment =
      EbrTestEnvironmentBuilder.new
                               .with_master_batch_record_json(mbr_json)
                               .with_connection(@connection)
                               .with_lot_number(@lot_number)
                               .build

    puts "Created new Production Record with lot number: #{@lot_number}_1"
  end

end
