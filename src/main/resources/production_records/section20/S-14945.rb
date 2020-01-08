# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = ('SIMPLE_MT_NAME')
    @master_template_id = ('SIMPLE_MT_ID')
    @today = Date.today.strftime('%Y-%m-%d')
    @today_modal = Date.today.strftime('%d-%b-%Y').gsub("-", " ")
    @yesterday = (Date.today - 1).strftime('%Y-%m-%d')
    @yesterday_modal = (Date.today - 1).strftime('%d-%b-%Y').gsub("-", " ")
    @tomorrow = (Date.today + 1).strftime('%Y-%m-%d')
    @tomorrow_modal = (Date.today + 1).strftime('%d-%b-%Y').gsub("-", " ")
    @day_after_tomorrow = (Date.today + 2).strftime('%Y-%m-%d')
    @day_after_tomorrow_modal = (Date.today + 2).strftime('%d-%b-%Y').gsub("-", " ")
    @lot_number_boundaries = uniq("Lot numbers ")
    @edited_boundaries = uniq("Edited lot numbers ")

    pre_test
    test_deviations_tile_navigates_to_active_deviations_page
    test_creating_new_deviation
    test_associating_a_deviation_to_a_master_template
    test_adding_lot_number_boundaries
    test_adding_date_boundaries
    test_deviation_doesnt_appear_if_not_within_active_dates
    test_edit_an_existing_deviation
    test_viewing_active_deviations_while_creating_a_batch_record
    test_deviations_list_shows_a_hyperlink_to_FBS_form
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
  end

  def test_deviations_tile_navigates_to_active_deviations_page
    @mc.go_to.ebr
    assert @mc.ebr.deviations_tile_element.visible?, "The Deviations tile is not shown"
    @mc.ebr.deviations_view_all
    assert @mc.production_deviations.page_header_element.attribute('innerText') == "Active MX Deviations"
  end

  def test_creating_new_deviation
    @mc.production_deviations.new_deviation
    assert @mc.production_deviations.modal_launch_button_element.visible?, "New deviation modal did not open"
  end

  def test_associating_a_deviation_to_a_master_template
    @mc.production_deviations.select_master_template @master_template
    @mc.wait_for_video time:1
    assert @mc.production_deviations.modal_master_template_field_element.attribute('innerText').strip == @master_template,
           "The Select Master Template field didn't display #{@master_template}."
  end

  def test_adding_lot_number_boundaries
    @mc.production_deviations.modal_lot_numbers_button
    @mc.production_deviations.modal_lot_numbers_field = @lot_number_boundaries
    form_number = launch_and_save_form_number
    assert @mc.production_deviations.in_list?(form_number),
           "The new deviation with form number '#{form_number}' was not found in the list."
    assert @mc.production_deviations.table_displays(column: 3, row: 1) == @lot_number_boundaries,
           "The lot number boundaries #{@lot_number_boundaries} were not found in the list."
  end

  def test_adding_date_boundaries
    @mc.production_deviations.new_deviation
    @mc.production_deviations.select_master_template @master_template
    @mc.production_deviations.set_start_date @today_modal
    @mc.production_deviations.set_end_date @tomorrow_modal
    form_number = launch_and_save_form_number
    assert @mc.production_deviations.in_list?(form_number),
           "The new deviation with form number '#{form_number}' was not found in the list."
    assert @mc.production_deviations.table_displays(column: 3, row: 1) == (@today + " to " + @tomorrow),
           "The date boundaries '#{@today} to #{@tomorrow}' were not found in the list."
  end

  def test_deviation_doesnt_appear_if_not_within_active_dates
    @mc.production_deviations.new_deviation
    @mc.production_deviations.select_master_template @master_template
    @mc.production_deviations.set_start_date @tomorrow_modal
    @mc.production_deviations.set_end_date @day_after_tomorrow_modal
    form_number = launch_and_save_form_number
    @mc.production_deviations.filter_by form_number
    assert !@mc.production_deviations.active_deviations_table_element.attribute('innerText').include?(form_number),
           "The new deviation with form number '#{form_number}' should not be in the list."
  end

  def test_edit_an_existing_deviation
    @mc.production_deviations.open_filter
    @mc.production_deviations.deviation_filter_reset
    @mc.production_deviations.close_filter
    form_number = @mc.production_deviations.table_displays
    @mc.production_deviations.edit_active_deviation form_number
    @mc.production_deviations.modal_lot_numbers_button
    @mc.production_deviations.modal_lot_numbers_field = @edited_boundaries
    @mc.production_deviations.modal_launch_button
    assert @mc.success.displayed
    assert @mc.production_deviations.in_list?(form_number),
           "The new deviation with form number '#{form_number}' was not found in the list."
    assert @mc.production_deviations.table_displays(column: 3, row: 1) == @edited_boundaries,
           "The lot number boundaries #{@edited_boundaries} were not found in the list."
  end

  def test_viewing_active_deviations_while_creating_a_batch_record
    @mc.go_to.ebr
    wait_until { @mc.ebr.batch_record_create_element.visible? }
    @mc.ebr.batch_record_create
    @mc.batch_record_creation.master_batch_record_element.click
    @mc.batch_record_creation.master_batch_record_search = "#{@master_template_id} #{@master_template} (Rev: A)"
    @mc.batch_record_creation.master_batch_record "#{@master_template_id} #{@master_template}"
    type = @mc.production_deviations.table_displays(column: 2, row: 1)
    assert type.include?(@master_template), "Cannot find the deviations list showing #{@master_template} in the 'TYPE' column."
  end

  def test_deviations_list_shows_a_hyperlink_to_FBS_form
    form_number = @mc.production_deviations.table_displays
    @mc.production_deviations.click_on_form_hyperlink form_number
    @mc.alert.ok if @mc.alert.visible?
    @mc.alert.ok if @mc.alert.visible?
    @mc.alert.ok if @mc.alert.visible?
    assert form_number == @mc.production_deviations.fbs_form_number, "The hyperlink to the FBS form did not work."
  end

  private

  def launch_and_save_form_number
    @mc.production_deviations.modal_launch_button
    @mc.alert.ok if @mc.alert.visible?
    @mc.alert.ok if @mc.alert.visible?
    @mc.alert.ok if @mc.alert.visible?
    form_number = @mc.production_deviations.fbs_form_number
    @mc.go_to.ebr.deviations_view_all
    form_number
  end
end
