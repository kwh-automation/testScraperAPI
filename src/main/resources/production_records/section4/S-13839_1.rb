require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq('equip_calibration_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')
    @asset_1 = uniq('asset_1')
    @asset_2 = uniq('asset_2')
    @next_due_date = (DateTime.now + 7).strftime("%d %b %Y")

    @connection = MCAPI.new

    pre_test
    test_adding_fbs_integration_step
    test_configuring_to_display_next_calibration_due_date
    test_next_calibration_due_date_appears_as_a_date_step
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.launch_calibration_form @asset_1, status: "Pass", next_due_date: @next_due_date, connection: @connection
    @mc.do.launch_calibration_form @asset_2, status: "Pass", next_due_date: @next_due_date, connection: @connection
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
  end

  def test_adding_fbs_integration_step
    @mc.phase_step.add_fbs_integration_step
    @mc.phase_step.fbs_integration_step.type_of_fbs_element.click
    @mc.phase_step.fbs_integration_step.choose_type 1
    @mc.phase_step.fbs_integration_step.add_equipment @asset_1
    @mc.phase_step.fbs_integration_step.add_equipment @asset_2
    @mc.wait_for_video time: 1
    @mc.phase_step.fbs_integration_step.save_fbs_integration
    assert (@mc.phase_step.phase_step_listed? "fbs integration", 1), "The FBS Integration Step is not visible."
    assert @mc.phase_step.fbs_integration_step.asset_exists_in_list?(0), "Equipment asset_1 is not in the list."
    assert @mc.phase_step.fbs_integration_step.asset_exists_in_list?(1), "Equipment asset_2 is not in the list."
  end

  def test_configuring_to_display_next_calibration_due_date
    @mc.phase_step.fbs_integration_step.toggle_display_due_date
    @mc.wait_for_video
    assert (@mc.phase_step.phase_step_listed? "date", 2), "The next calibration due date (date step) is not visible."
    @mc.phase_step.click_on_step_label 1, type: "fbs-integration"
    @mc.phase_step.fbs_integration_step.toggle_display_due_date
    assert (@mc.phase_step.phase_step_removed? "date", 2),
           "The next calibration due date (date step) was not deleted when the switch was turned off."
    @mc.phase_step.fbs_integration_step.toggle_display_due_date
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot
    @mc.ebr_navigation.go_to_first "Phase", @lot
  end

  def test_next_calibration_due_date_appears_as_a_date_step
    @step_one = @mc.phase.phase_steps[0]
    @step_one.select_option 1
    @mc.wait_for_video
    assert ((Date.parse (@mc.phase.phase_steps[1].captured_value)) == (Date.parse (@next_due_date))),
           "The auto-captured date step was expected to be #{@next_due_date}"
  end
end
