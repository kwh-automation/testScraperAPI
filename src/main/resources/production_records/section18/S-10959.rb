require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("aql_groups")
    @product_id = uniq("aql_groups", false)
    @lot_number = uniq("lot_", true)
    @release_role_id = '00000000000FTADMIN'
    @group = ["Group 1", "Group 2"]
    @severity = ["ZERO_TOLERANCE", "CRITICAL", "MAJOR", "MINOR"]

    @connection = MCAPI.new

    pre_test
    test_user_can_create_aql_group_using_add_a_group_option_and_named
    test_user_can_assign_accept_reject_numbers_to_severity_defined_in_group
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
  end

  def test_user_can_create_aql_group_using_add_a_group_option_and_named
    @mc.manage_inspections.add_group "Group 1"
  end

  def test_user_can_assign_accept_reject_numbers_to_severity_defined_in_group
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[0], 10
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[1], 10
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[2], 10
    @mc.manage_inspections.group_reject_threshold @group[0], @severity[3], 10
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
