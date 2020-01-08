require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("inspection_review")
    @product_id = uniq("inspection_review", false)
    @lot_number = uniq("lot_", true)
    @group = uniq("Group")
    @release_role_id = '00000000000FTADMIN'

    @connection = MCAPI.new

    pre_test
    test_review_by_exception_page_shows_indivdual_aql_failures
    test_review_by_exception_page_shows_group_aql_failures
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
    @mc.manage_inspections.add_group @group
    @mc.manage_inspections.assign_phase_steps
    @mc.assign_phase_steps.step 3
    @mc.assign_phase_steps.step 4
    @mc.assign_phase_steps.assign
    @mc.manage_inspections.group_reject_threshold @group, "ZERO_TOLERANCE", 1
    @mc.ebr_navigation.go_to_first('phase', @lot_number + "_1")
    @mc.phase.phase_steps[0].select_fail
    @mc.phase.phase_steps[1].select_pass
    @mc.phase.phase_steps[2].select_pass
    @mc.phase.phase_steps[3].select_fail
  end

  def test_review_by_exception_page_shows_indivdual_aql_failures
    @mc.ebr_navigation.review_by_exception
    wait_until {@mc.review_by_exception.toggle_aql_defects_element.visible?}
    assert @mc.review_by_exception.toggle_aql_defects_element.attribute("innerText") == "2"
    @mc.review_by_exception.aql_defects_tab
    @mc.wait_for_video
    assert (@mc.review_by_exception.aql_step_details 0).include? '1.1.1.1'
  end

  def test_review_by_exception_page_shows_group_aql_failures
    @mc.review_by_exception.toggle_gadget "6"
    assert (@mc.review_by_exception.aql_step_details 1, group: true).include? '1.1.1.4'
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