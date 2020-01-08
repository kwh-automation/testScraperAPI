require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-16646_', false)
    @release_role_id = '00000000000FTADMIN'
    @product_id = uniq('Prod_id_S-16646_', false)
    @lot_number = uniq('lot_S-16646_', true)
    @mbr_name = uniq('S-16646_', false)
    @erp_configuration = 'http://mcusdevmfg.mainman.dcs:8998'
    @valid_endpoint = '/materials/lots?materialId=sand002'
    @invalid_endpoint = 'invalid_endpoint'

    pre_test
    test_that_api_configuration_requires_third_party_system_configured
    test_that_api_url_is_populated
    test_that_valid_endpoint_generates_preview
    test_that_user_can_select_primary_key
    test_that_optional_capture_can_be_selected
    test_that_data_types_can_be_selected_and_configured
    publish_approve_and_navigate_to_production_record
    test_that_phase_steps_function_on_execution
  end

  def test_that_api_configuration_requires_third_party_system_configured
    @mc.go_to.ebr
    clear_erp_configuration_and_set_valid_address
    setup_erp_connection
    navigate_to_phase_steps_of_created_mbr
  end

  def test_that_api_url_is_populated
    @mc.phase_step._api_config_button
    text = @mc.api_config_wizard.api_address_field_element.attribute('value')
    assert text.length > 0 and text != nil
  end

  def test_that_valid_endpoint_generates_preview
    assert !endpoint_generates_table_preview?(@invalid_endpoint)
    @mc.api_config_wizard.endpoint_field_element.send_keys([:control, 'a', :delete])
    assert endpoint_generates_table_preview? @valid_endpoint
    @mc.api_config_wizard.compare_head_to_body
  end

  def test_that_user_can_select_primary_key
    @mc.api_config_wizard.select_primary_key_by_position 1
  end

  def test_that_optional_capture_can_be_selected
    @mc.api_config_wizard.select_capture_by_position 2
    @mc.api_config_wizard.select_capture_by_position 4
    @mc.api_config_wizard.select_capture_by_position 6
    sleep 1
  end

  def test_that_data_types_can_be_selected_and_configured
    @mc.api_config_wizard.select_column_data_type_by_position 2, 'Text'
    @mc.api_config_wizard.select_column_data_type_by_position 4, 'Numeric'
    @mc.api_config_wizard.select_column_data_type_by_position 6, 'Date'
    sleep 1
    @mc.api_config_wizard.save_button
    api_phase_steps_added?
  end

  def test_that_phase_steps_function_on_execution
    @mc.wait_for_video
    @mc.batch_phase_step.set_text('2001', '1.1.1.1')
    @mc.wait_for_video
    @mc.batch_phase_step.data_type_as_expected? 'api capture', '1.1.1.1'
    @mc.batch_phase_step.data_captured? phase_step: 1
    @mc.batch_phase_step.data_type_as_expected? 'general text', '1.1.1.2'
    @mc.batch_phase_step.data_captured? phase_step: 2
    @mc.batch_phase_step.data_type_as_expected? 'general numeric', '1.1.1.3'
    @mc.batch_phase_step.data_captured? phase_step: 3
    @mc.batch_phase_step.data_type_as_expected? 'date', '1.1.1.4'
    @mc.batch_phase_step.data_captured? phase_step: 4
    @mc.batch_phase_step.complete
    @mc.batch_phase_step.structure_levels_complete?
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.go_to.ebr
    create_master_template
  end

  private
  def api_phase_steps_added?
    @mc.phase_step.select_phase_step_by_position 1
    assert @mc.phase_step.phase_step_listed? 'api-step', 1
    assert @mc.phase_step.phase_step_listed? 'general-text', 2
    assert @mc.phase_step.phase_step_listed? 'numeric-data', 3
    assert @mc.phase_step.phase_step_listed? 'date', 4
  end

  def setup_erp_connection
    @mc.erp_settings.authentication_element.click
    @mc.erp_settings.bearer_token_authentication
    @mc.erp_settings.bearer_token_element.send_keys([:control, 'a'])
    @mc.erp_settings.bearer_token_element.send_keys(:delete)
    @mc.erp_settings.bearer_token_element.send_keys uniq("bearer_token")
    @mc.erp_settings.save
  end

  def clear_erp_configuration_and_set_valid_address
    @mc.ebr.erp_configuration
    @mc.erp_settings.erp_address_element.send_keys([:control, 'a'])
    @mc.erp_settings.erp_address_element.send_keys(:delete)
    @mc.erp_settings.erp_address_element.send_keys @erp_configuration
  end

  def publish_approve_and_navigate_to_production_record
    @mc.phase_step.back
    @mc.structure_builder.publish_mbr_from_structure_builder
    MCAPIs.approve_MBR @mbr_name
    create_production_record_and_navigate_to_it
  end

  def create_production_record_and_navigate_to_it
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_phase @lot_number, 1
  end

  def endpoint_generates_table_preview?(endpoint)
    @mc.api_config_wizard.send_keys_to_endpoint_field endpoint
    @mc.api_config_wizard.test_connection_button
    @mc.api_config_wizard.table_preview_element.exists?
  end

  def navigate_to_phase_steps_of_created_mbr
    @mc.go_to.ebr.view_all_master_batch_records
    @mc.master_batch_record_list.filter_by :product_id, @product_id
    @mc.master_batch_record_list.edit_master_batch_record @product_id
    @mc.structure_builder.procedure_level.select_unit 1
    @mc.structure_builder.operation_level.select_unit 1
    @mc.structure_builder.phase_level.configure_phase 1
  end

  def create_master_template
    puts 'Creating Master Template 2 phase steps...'

    phase_1 = PhaseFactory.phase_customizer()
                  .with_title('Phase 1')
                  .with_order_label('1.1.1')
                  .with_order_number(1)
                  .build

    mbr_json = MasterBatchRecordBuilder.new
                   .with_unit_procedure(UnitProcedureBuilder.new
                                            .with_operation(OperationBuilder.new
                                                                .with_phase(phase_1).build).build)
                   .with_product_id(@product_id)
                   .with_product_name(@mbr_name)
                   .with_release_role_id(@release_role_id)
                   .build

    @test_environment =
        EbrTestEnvironmentBuilder.new
            .with_master_batch_record_json(mbr_json)
            .with_connection(@connection)
            .with_lot_number(@lot_number)
            .build

    puts "Finished creating Master Template as #{@product_id}"
  end

end
