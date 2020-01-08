require "mastercontrol-test-suite"

class ProductionRecordsFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @mbr_name = uniq("aql_")
    @product_id = uniq("aql_", false)
    @lot_number = uniq("lot_", true)
    @release_role_id = '00000000000FTADMIN'

    @connection = MCAPI.new

    pre_test
    test_verifying_aql_running_total_appears_when_configured
    test_verifying_aql_button_shows_green_check
    test_verifying_aql_running_list_displays_current_step_status
    test_verifying_aql_button_shows_red_alert
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
    @mc.manage_inspections.add_reject_count 1, row: 1
    @mc.manage_inspections.add_reject_count 2, row: 2
    @mc.ebr_navigation.go_to_first('phase', @lot_number + "_1")
  end

  def test_verifying_aql_running_total_appears_when_configured
    assert @mc.ebr_navigation.aql_running_total_element.visible?
  end

  def test_verifying_aql_button_shows_green_check
    assert @mc.ebr_navigation.aql_pass_icon_element.visible?
    @mc.wait_for_video
  end

  def test_verifying_aql_running_list_displays_current_step_status
    @mc.phase.phase_steps[0].select_fail
    @mc.phase.phase_steps[1].select_fail

    wait_until { @mc.ebr_navigation.aql_running_total_element.visible? }
    @mc.ebr_navigation.aql_running_total
    assert (@mc.ebr_navigation.aql_running_total_element.attribute("class").include? "dropdown ng-star-inserted open")
    assert (@mc.ebr_navigation.get_aql_step_running_total_icon_data "1-1-1-1").include? "fail"
    assert (@mc.ebr_navigation.get_aql_step_running_total_icon_data "1-1-1-2").include? "pass"
    @mc.wait_for_video
  end

  def test_verifying_aql_button_shows_red_alert
    assert @mc.ebr_navigation.aql_fail_icon_element.visible?
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