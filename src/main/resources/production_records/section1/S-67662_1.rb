# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_id = uniq('prod_id_')
    @product_name = uniq('name_')
    @lot_one = uniq('lot_1_')
    @lot_two = uniq('lot_2_')
    @template = "#{@product_id} #{@product_name}"
    @error_message = 'Sort order is wrong'

    pre_test
    test_creating_one_or_more_production_records
    test_navigating_to_production_record
    test_filtering_production_records
    test_sorting_production_records
    test_that_actions_can_be_performed_on_the_production_record
    test_that_production_record_information_is_displayed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def test_creating_one_or_more_production_records
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    wait_until(5) { @mc.batch_record_creation.master_batch_record? }
    @mc.batch_record_creation.master_batch_record @template
    @mc.batch_record_creation.lot_number = @lot_one
    @mc.batch_record_creation.lot_amount = 1
    @mc.batch_record_creation.create
    assert @mc.success.displayed
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
    wait_until(5) { @mc.batch_record_creation.master_batch_record? }
    @mc.batch_record_creation.master_batch_record @template
    @mc.batch_record_creation.lot_number = @lot_two
    @mc.batch_record_creation.lot_amount = 1
    @mc.batch_record_creation.create
    assert @mc.success.displayed
    @mc.go_to.ebr
  end

  def test_navigating_to_production_record
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_two
    assert @mc.subnavbar.get_navbar_page_title.include?(@lot_two), "Page title did not match #{@lot_two}"
  end

  def test_filtering_production_records
    @mc.go_to.ebr.view_all_br
    total = @mc.batch_record_list.get_unfiltered_total_records
    @mc.batch_record_list.filter_by(:product_id, @product_id)
    assert @mc.batch_record_list.x_of_y_contains?(2, total), 'Incorrect number of items in the list'
  end

  def test_sorting_production_records
    sort_by_lot_number
    sort_by_product_id
    sort_by_product_name
    sort_by_created_date_time
  end

  def test_that_actions_can_be_performed_on_the_production_record
    @mc.batch_record_list.filter_by :lot_number, @lot_one
    assert @mc.batch_record_list.batch_record_dropdown_exists?(@lot_one), 'Drop down does not exist'
  end

  def test_that_production_record_information_is_displayed
    assert @mc.batch_record_list.get_lot_number_data(0).include?(@lot_one), "#{@lot_one} not found"
    assert @mc.batch_record_list.get_product_id_data(0).include?(@product_id), "#{@product_id} not found"
    assert @mc.batch_record_list.get_product_name_data(0).include?(@product_name), "#{@product_name} not found"
    assert @mc.batch_record_list.get_status_data(0).include?('Open'), 'Status is not "Open"'
    assert @mc.do.check_time(@mc.batch_record_list.get_start_date_data(0)), 'Time is incorrect'
  end

  private

  def sort_by_lot_number
    initial_top_of_the_list_lot_number = @mc.batch_record_list.batch_record_list_table[0][0]
    @mc.batch_record_list.lot_number_header
    new_sorted_top_of_the_list_lot_number = @mc.batch_record_list.batch_record_list_table[0][0]
    assert new_sorted_top_of_the_list_lot_number < initial_top_of_the_list_lot_number, @error_message

    @mc.batch_record_list.lot_number_header
    initial_top_of_the_list_lot_number = new_sorted_top_of_the_list_lot_number
    new_sorted_top_of_the_list_lot_number = @mc.batch_record_list.batch_record_list_table[0][0]
    assert new_sorted_top_of_the_list_lot_number > initial_top_of_the_list_lot_number, @error_message
  end

  def sort_by_product_id
    initial_top_of_the_list_product_id = @mc.batch_record_list.batch_record_list_table[0][1]
    @mc.batch_record_list.product_id_header
    new_sorted_top_of_the_list_product_id = @mc.batch_record_list.batch_record_list_table[0][1]
    assert new_sorted_top_of_the_list_product_id <= initial_top_of_the_list_product_id, @error_message

    @mc.batch_record_list.product_id_header
    initial_top_of_the_list_product_id = new_sorted_top_of_the_list_product_id
    new_sorted_top_of_the_list_product_id = @mc.batch_record_list.batch_record_list_table[0][1]
    assert new_sorted_top_of_the_list_product_id >= initial_top_of_the_list_product_id, @error_message
  end

  def sort_by_product_name
    initial_top_of_the_list_product_name = @mc.batch_record_list.batch_record_list_table[0][2]
    @mc.batch_record_list.product_name_header
    new_sorted_top_of_the_list_product_name = @mc.batch_record_list.batch_record_list_table[0][2]
    assert new_sorted_top_of_the_list_product_name <= initial_top_of_the_list_product_name, @error_message

    @mc.batch_record_list.product_name_header
    initial_top_of_the_list_product_name = new_sorted_top_of_the_list_product_name
    new_sorted_top_of_the_list_product_name = @mc.batch_record_list.batch_record_list_table[0][2]
    assert new_sorted_top_of_the_list_product_name >= initial_top_of_the_list_product_name, @error_message
  end

  def sort_by_created_date_time
    initial_top_of_the_list_created_date_time = @mc.batch_record_list.batch_record_list_table[0][4]
    @mc.batch_record_list.created_date_time
    new_sorted_top_of_the_list_created_date_time = @mc.batch_record_list.batch_record_list_table[0][4]
    assert new_sorted_top_of_the_list_created_date_time <= initial_top_of_the_list_created_date_time, @error_message

    @mc.batch_record_list.created_date_time
    initial_top_of_the_list_created_date_time = new_sorted_top_of_the_list_created_date_time
    new_sorted_top_of_the_list_created_date_time = @mc.batch_record_list.batch_record_list_table[0][4]
    assert new_sorted_top_of_the_list_created_date_time >= initial_top_of_the_list_created_date_time, @error_message
  end
end
