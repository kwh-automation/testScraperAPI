require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04501_", false)
    @product_id = uniq("1", false)
    @reasons = ["Instrument Error", "Calibration Error", "Entered Wrong Information"]

    pre_test
    test_corrections_can_be_configured_to_include_pre_defined_reasons
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
    add_data_type_general_text
  end

  def test_corrections_can_be_configured_to_include_pre_defined_reasons
    @mc.phase_step.general_text.enable_correction_reason if @mc.phase_step.general_text.is_corrections_enabled?
    assert @mc.phase_step.general_text.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.general_text.choose_correction_reason reason
    end
    assert @mc.phase_step.general_text.is_corrections_enabled?
    assert @mc.phase_step.general_text.is_correction_reason_enabled?
    @mc.phase_step.general_text.remove_tag("1", "corrections")
  end

private
  def add_data_type_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block "1", text:"Generic Text Step 1"
  end
end
