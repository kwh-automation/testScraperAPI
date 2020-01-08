require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @master_template = uniq('equip_calibration_')
    @product_id = uniq('id_')
    @lot = uniq('lot_')

    @asset_1 = uniq('valid_1_')
    @asset_2 = uniq('valid_2_')
    @asset_3 = uniq('expired_3_')
    @asset_4 = uniq('failed_calibration_4_')

    @valid_next_due_date = (DateTime.now + 7).strftime("%d %b %Y")
    @expired_next_due_date = (DateTime.now - 7).strftime("%d %b %Y")
    @connection = MCAPI.new

    pre_test
    test_selecting_available_equipment
    test_unable_to_add_equipment_with_expired_calibration
    test_unable_to_add_equipment_that_has_failed_inspection
    test_can_launch_a_form_for_invalid_equipment_options
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    create_asset @asset_1, "Big Scale", "Pass", @valid_next_due_date
    create_asset @asset_2, "Small Scale", "Pass", @valid_next_due_date
    create_asset @asset_3, "Next calibration due date is in the past", "Pass", @expired_next_due_date
    create_asset @asset_4, "Failed most recent calibration", "Fail", @valid_next_due_date
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    2.times do
      @mc.phase_step.add_fbs_integration_step
      @mc.phase_step.fbs_integration_step.type_of_fbs_element.click
      @mc.phase_step.fbs_integration_step.choose_type 1
      @mc.phase_step.fbs_integration_step.add_equipment @asset_1
      @mc.phase_step.fbs_integration_step.add_equipment @asset_2
      @mc.phase_step.fbs_integration_step.add_equipment @asset_3
      @mc.phase_step.fbs_integration_step.add_equipment @asset_4
      @mc.phase_step.fbs_integration_step.save_fbs_integration
    end
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot
    @mc.ebr_navigation.go_to_first "Phase", @lot
  end

  def test_selecting_available_equipment
    @fbs_integration_step = @mc.phase.phase_steps[1]
    @fbs_integration_step.select_option 1
    @mc.wait_for_video
    assert (@fbs_integration_step.captured_value == @asset_1), "The user wasn't able to select asset_1."
  end

  def test_unable_to_add_equipment_with_expired_calibration
    @fbs_integration_step = @mc.phase.phase_steps[0]
    @mc.wait_for_video
    assert !(@fbs_integration_step.is_option_enabled? 3), "Option 3 should be disabled."
  end

  def test_unable_to_add_equipment_that_has_failed_inspection
    @mc.wait_for_video
    assert !(@fbs_integration_step.is_option_enabled? 4), "Option 4 should be disabled."
  end

  def test_can_launch_a_form_for_invalid_equipment_options
    @mc.batch_phase_step.open_menu
    @mc.batch_phase_step.launch_form "1.1.1.1"
    @mc.batch_record_form_launch.select_form "1.1.1.1"
    @mc.batch_record_form_launch.launch
    wait_until { !@mc.batch_record_form_launch.cancel_element.visible? }
    @mc.batch_phase_step.launched_form "1.1.1.1"
    wait_until(30) { @mc.ztest_form01.form_number? }
  end

  private

  def create_asset title, description, status, date
    @mc.do.launch_calibration_form title,
                                   description: description,
                                   status: status,
                                   next_due_date: date,
                                   type: "Scale",
                                   connection: @connection
  end
end
