require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04501_", false)
    @product_id = uniq("1", false)
    @reasons = ["Instrument Error", "Calibration Error", "Entered Wrong Information"]
    @count = 1

    pre_test
    test_add_field_correction_property_to_general_text
    test_add_field_correction_property_to_numeric_data
    test_add_field_correction_property_to_step_completion
    test_add_field_correction_property_to_multiple_choice
    test_add_field_correction_property_to_attachment
    test_add_field_correction_property_to_pass_fail
    test_add_field_correction_property_to_date
    test_add_field_correction_property_to_date_time
    test_add_field_correction_property_to_hyperlink
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
  end

  def test_add_field_correction_property_to_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count, text:"Generic Text Step #{@count}"
    @mc.phase_step.general_text.enable_correction_reason if @mc.phase_step.general_text.is_corrections_enabled?
    assert @mc.phase_step.general_text.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.general_text.choose_correction_reason reason
    end
    assert @mc.phase_step.general_text.is_corrections_enabled?
    assert @mc.phase_step.general_text.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_numeric_data
    @count = @count + 1
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block @count, text:"Numeric Step #{@count}"
    @mc.phase_step.numeric_data.enable_correction_reason if @mc.phase_step.numeric_data.is_corrections_enabled?
    assert @mc.phase_step.numeric_data.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.numeric_data.choose_correction_reason reason
    end
    assert @mc.phase_step.numeric_data.is_corrections_enabled?
    assert @mc.phase_step.numeric_data.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_step_completion
    @count = @count + 1
    @mc.phase_step.add_completion_step
    @mc.phase_step.completion_step.add_text_block @count, text:"Completion Step #{@count}"
    @mc.phase_step.completion_step.enable_correction_reason if @mc.phase_step.completion_step.is_corrections_enabled?
    assert @mc.phase_step.completion_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.completion_step.choose_correction_reason reason
    end
    assert @mc.phase_step.completion_step.is_corrections_enabled?
    assert @mc.phase_step.completion_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_multiple_choice
    @count = @count + 1
    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.add_text_block @count, text:"Multiple Choice Step #{@count}"
    @mc.phase_step.multiple_choice_step.enable_correction_reason if @mc.phase_step.multiple_choice_step.is_corrections_enabled?
    assert @mc.phase_step.multiple_choice_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.multiple_choice_step.choose_correction_reason reason
    end
    assert @mc.phase_step.multiple_choice_step.is_corrections_enabled?
    assert @mc.phase_step.multiple_choice_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_attachment
    @count = @count + 1
    @mc.phase_step.add_attachment_step
    @mc.phase_step.attachment_step.add_text_block @count, text:"Attachment Step #{@count}"
    @mc.phase_step.attachment_step.enable_correction_reason if @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.attachment_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.attachment_step.choose_correction_reason reason
    end
    assert @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.attachment_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_pass_fail
    @count = @count + 1
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.add_text_block @count, text:"Pass Fail Step #{@count}"
    @mc.phase_step.pass_fail_step.enable_correction_reason if @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.pass_fail_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.pass_fail_step.choose_correction_reason reason
    end
    assert @mc.phase_step.pass_fail_step.is_corrections_enabled?
    assert @mc.phase_step.pass_fail_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_date
    @count = @count + 1
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block @count, text:"Date Step #{@count}"
    @mc.phase_step.date_step.enable_correction_reason if @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.date_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.date_step.choose_correction_reason reason
    end
    assert @mc.phase_step.date_step.is_corrections_enabled?
    assert @mc.phase_step.date_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_date_time
    @count = @count + 1
    @mc.phase_step.add_date_time_step
    @mc.phase_step.date_time_step.add_text_block @count, text:"Date Time Step #{@count}"
    @mc.phase_step.date_time_step.enable_correction_reason if @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.date_time_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.date_time_step.choose_correction_reason reason
    end
    assert @mc.phase_step.date_time_step.is_corrections_enabled?
    assert @mc.phase_step.date_time_step.is_correction_reason_enabled?
  end

  def test_add_field_correction_property_to_hyperlink
    @count = @count + 1
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step.hyperlink_step.custom_link_tab
    @mc.phase_step.hyperlink_step.add_title "hyperlink"
    @mc.phase_step.hyperlink_step.add_url "https://www.google.com"
    @mc.phase_step.hyperlink_step.save
    @mc.phase_step.hyperlink_step.add_text_block @count, text:"Hyperlink Step #{@count}"
    @mc.phase_step.hyperlink_step.enable_correction_reason if @mc.phase_step.attachment_step.is_corrections_enabled?
    assert @mc.phase_step.hyperlink_step.is_correction_reason_enabled?
    @mc.phase_step.reason_toolbar
    @reasons.each do |reason|
      @mc.phase_step.hyperlink_step.choose_correction_reason reason
    end
    assert @mc.phase_step.hyperlink_step.is_corrections_enabled?
    assert @mc.phase_step.hyperlink_step.is_correction_reason_enabled?
  end

end
