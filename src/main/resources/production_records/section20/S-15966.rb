require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq('S-15966_', false)
    @release_role_id = '00000000000FTADMIN'
    @product_id = uniq('Prod_id_S-15966_', false)
    @lot_number = uniq("lot_S-15966_", true)
    @mbr_name = uniq('S-15966_')
    @delete_tag = 'a-delete-tag'
    @configuration_tag = 'configuration-tag'
    @type_ahead_tag = 'type-ahead-tag'
    @duplicate_tag = 'duplicate-tag'
    @created_in_builder_tag = 'created-in-builder-tag'
    @remove_in_phase_step_tag = 'remove-tag'
    @invalid_tags = ['underscore_tag', 'space tag', 'bad-Case', '1tag']
    @valid_tags = ['dash-tag', 'tag-with-number-1', 'nodashes']

    pre_test
    test_that_tags_can_be_created_via_api_tag_configuration_tile
    test_that_tags_must_be_lowercase_and_separated_by_dashes
    test_that_deleted_tags_are_removed_from_production_records
    test_that_user_can_add_none_one_or_many_tags_to_phase_step
    test_that_user_can_create_unique_tags_from_phase_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.go_to.ebr
    create_master_template
  end

  def test_that_tags_can_be_created_via_api_tag_configuration_tile
    @mc.go_to.ebr.api_tag_configuration
    @mc.api_tag_configuration.create_api_tag @configuration_tag
    @mc.api_tag_configuration.create_api_tag @type_ahead_tag
  end

  def test_that_tags_must_be_lowercase_and_separated_by_dashes
    invalid_tag_configurations
    valid_tag_configurations
  end

  def test_that_deleted_tags_are_removed_from_production_records
    add_tag_to_be_deleted_to_phase_step
    sleep 1
    delete_tag_and_verify_no_longer_on_phase_step
  end

  def test_that_user_can_add_none_one_or_many_tags_to_phase_step
    @mc.phase_step.select_phase_step_by_position 1
    @mc.phase_step.create_api_tag @duplicate_tag, 'pass-fail'
    @mc.phase_step.create_api_tag @remove_in_phase_step_tag, 'pass-fail'
    tags_can_be_removed_from_phase_step?
    type_ahead_works_with_previously_created_tags?
  end

  def test_that_user_can_create_unique_tags_from_phase_step
    @mc.phase_step.create_api_tag @created_in_builder_tag, 'pass-fail'
    sleep 0.5
    @mc.phase_step.create_api_tag @created_in_builder_tag, 'pass-fail'
    added_tags_are_listed_in_pill_below_phase_step?
  end

  def clean_up
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.go_to.ebr.api_tag_configuration
    @mc.api_tag_configuration.delete_all_api_tags
  end

  private
  def add_tag_to_be_deleted_to_phase_step
    @mc.api_tag_configuration.create_api_tag @delete_tag
    sleep 1
    @mc.api_tag_configuration.done_button
    navigate_to_phase_steps_of_created_mbr
    @mc.phase_step.select_phase_step_by_position 1
    @mc.phase_step.toggle_api_tag_drawer 'pass-fail'
    @mc.phase_step.create_api_tag @delete_tag, 'pass-fail'
    @mc.phase_step.back
  end

  def delete_tag_and_verify_no_longer_on_phase_step
    @mc.go_to.ebr.api_tag_configuration
    @mc.api_tag_configuration.delete_api_tag @delete_tag
    @mc.api_tag_configuration.done_button
    navigate_to_phase_steps_of_created_mbr
    @mc.phase_step.select_phase_step_by_position 1
    @mc.phase_step.toggle_api_tag_drawer 'pass-fail'
    assert !@mc.phase_step.does_api_tag_exist_on_selected_phase_step?(@delete_tag)
    @mc.phase_step.clear_active_api_tag_input_text_field
  end

  def type_ahead_works_with_previously_created_tags?
    @mc.phase_step.send_api_tag_name @type_ahead_tag, 'pass-fail'
    assert @mc.phase_step.type_ahead_dropdown_visible?
    @mc.phase_step.send_api_tag_name [:control, 'a', :delete], 'pass-fail'
  end

  def tags_can_be_removed_from_phase_step?
    @mc.phase_step.remove_api_phase_step_tag @remove_in_phase_step_tag
    @count = @mc.phase_step.count_child_elements_using_css '.api-tags-list', 'li'
    assert @count == 1
  end

  def added_tags_are_listed_in_pill_below_phase_step?
    assert @mc.phase_step.does_api_tag_exist_on_selected_phase_step? @duplicate_tag
    assert @mc.phase_step.does_api_tag_exist_on_selected_phase_step? @created_in_builder_tag
  end

  def invalid_tag_configurations
    @invalid_tags.each do |tag|
      @mc.api_tag_configuration.create_api_tag(tag)
      assert !@mc.api_tag_configuration.tag_library_list_item_exists?(tag, false)
      sleep 0.5
      @mc.api_tag_configuration.tag_name_element.send_keys ([:control, 'a', :delete])
    end
  end

  def valid_tag_configurations
    @valid_tags.each do |tag|
      @mc.api_tag_configuration.create_api_tag(tag)
      assert @mc.api_tag_configuration.tag_library_list_item_exists?(tag, false)
      sleep 0.5
    end
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
                  .with_phase_step(PassFailBuilder.new
                                       .with_order_label('1.1.1.1')
                                       .with_title('phase step with tags')
                                       .build)
                  .with_phase_step(PassFailBuilder.new
                                       .with_order_label('1.1.1.2')
                                       .with_title('phase step with tags 1')
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

    @test_environment =
        EbrTestEnvironmentBuilder.new
            .with_master_batch_record_json(mbr_json)
            .with_connection(@connection)
            .with_lot_number(@lot_number)
            .build

    puts "Finished creating Master Template as #{@product_id}"
  end

end
