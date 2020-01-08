require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_1 = uniq("Pro_1_")
    @product_2 = uniq("Pro_2_")
    @uniq_common = uniq('')
    @mbr_name = uniq("Name_")
    @mbr_id = uniq("ID_")

    pre_test
    test_creating_new_master_template
    test_navigating_to_master_templates
    test_filtering_master_templates
    test_sorting_master_templates
    test_that_actions_can_be_performed_on_the_master_template
    test_that_master_template_information_is_displayed
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection

    mbr_json = []

    mbr_json << MasterBatchRecordBuilder.new.with_product_name(@product_1).with_product_id(@product_1).build

    mbr_json << MasterBatchRecordBuilder.new.with_product_name(@product_2).with_product_id(@product_2).build

    @test_environment = EbrTestEnvironmentBuilder.new.with_master_batch_record_json(mbr_json).with_connection(connection).build
  end

  def test_creating_new_master_template
    @mc.do.create_master_batch_record @mbr_name, @mbr_id
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.back

    @mc.go_to.ebr.view_all_mbr
    @mc.master_batch_record_list.filter_by(:product_id, @uniq_common)
    assert @mc.master_batch_record_list.master_batch_record_exists? @mbr_id
  end

  def test_navigating_to_master_templates
    @mc.master_batch_record_list.filter_by(:product_id, @mbr_id)
    @mc.master_batch_record_list.edit_master_batch_record @mbr_id
    assert @mc.procedure_level.procedure_level?
  end

  def test_filtering_master_templates
    @mc.go_to.ebr.view_all_mbr
    @mc.master_batch_record_list.filter_by(:product_id, @uniq_common)
    @total_records = @mc.master_batch_record_list.get_total_records
    assert @mc.master_batch_record_list.get_x_of_filtered_results == 3
  end

  def test_sorting_master_templates
    @mc.master_batch_record_list.filter_by(:product_id, @uniq_common)
    initial_top_of_the_list_product_id = @mc.master_batch_record_list.master_batch_record_list_table[0][0]
    @mc.master_batch_record_list.prod_id_header
    new_sorted_top_of_the_list_product_id = @mc.master_batch_record_list.master_batch_record_list_table[0][0]
    assert new_sorted_top_of_the_list_product_id < initial_top_of_the_list_product_id

    @mc.master_batch_record_list.prod_id_header
    initial_top_of_the_list_product_id = new_sorted_top_of_the_list_product_id
    new_sorted_top_of_the_list_product_id = @mc.master_batch_record_list.master_batch_record_list_table[0][0]
    assert new_sorted_top_of_the_list_product_id > initial_top_of_the_list_product_id
  end

  def test_that_actions_can_be_performed_on_the_master_template
    assert @mc.master_batch_record_list.master_batch_record_dropdown_exists? @mbr_id
  end

  def test_that_master_template_information_is_displayed
    @mc.master_batch_record_list.filter_by(:product_id, @mbr_id)
    assert @mc.master_batch_record_list.get_product_id_data(0).include?(@mbr_id)
    assert @mc.master_batch_record_list.get_product_name_data(0).include?(@mbr_name)
    assert @mc.master_batch_record_list.get_revision_data(0).include?("0")
    assert @mc.master_batch_record_list.get_lifecycle_data(0).include?("Draft")
  end

end
