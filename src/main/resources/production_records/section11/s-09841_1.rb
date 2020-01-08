require "mastercontrol-test-suite"

class ProductionRecordsFRS < MCValidationTest

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq("NA_", false)
    @product_id = uniq("1", false)
    @count = 1
    @lot_number = uniq("Lot")

    pre_test
    test_setting_a_phase_step_to_not_applicable
    test_verifying_not_applicable_is_not_available_when_not_configured
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count, text:"Text Step #{@count}"
    @mc.phase_step.general_text.enable_not_applicable
    assert @mc.phase_step.general_text.is_not_applicable_enabled?
    @count = @count + 1
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count, text:"Text Step #{@count}"
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_id, @product_name
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", @lot_number
    @mc.ebr_navigation.go_to_first "Phase", @lot_number
  end

  def test_setting_a_phase_step_to_not_applicable
    @mc.phase.phase_steps[0].not_applicable
    @mc.no_longer_applicable.yes
    @mc.wait_for_video
    assert @mc.phase.phase_steps[0].performer.include? @admin.downcase
    captured_text = @mc.phase.phase_steps[0].no_longer_applicable_captured "1.1.1.1"
    assert captured_text.include? "No Longer Applicable"
  end

  def test_verifying_not_applicable_is_not_available_when_not_configured
   assert !(@mc.phase.phase_steps[1].not_applicable_available?)
  end

end