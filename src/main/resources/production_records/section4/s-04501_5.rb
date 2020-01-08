require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("S04501_", false)
    @product_id = uniq("1", false)
    @count = 1
    @asset = uniq('asset')
    @fail_message = "Verification property is not enabled."
    @connection = MCAPI.new

    pre_test
    test_add_field_verification_property_to_general_text
    test_add_field_verification_property_to_numeric_data
    test_add_field_verification_property_to_step_completion
    test_add_field_verification_property_to_multiple_choice
    test_add_field_verification_property_to_attachment
    test_add_field_verification_property_to_pass_fail
    test_add_field_verification_property_to_date
    test_add_field_verification_property_to_date_time
    test_add_field_verification_property_to_hyperlink
    test_add_field_verification_property_to_form_launch
    test_add_field_verification_property_to_fbs_integration
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.launch_calibration_form @asset, connection: @connection
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
  end

  def test_add_field_verification_property_to_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count, text:"Generic Text Step #{@count}"
    @mc.phase_step.general_text.enable_verification
    assert @mc.phase_step.general_text.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_numeric_data
    @count += 1
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block @count, text:"Numeric Step #{@count}"
    @mc.phase_step.numeric_data.enable_verification
    assert @mc.phase_step.numeric_data.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_step_completion
    @count += 1
    @mc.phase_step.add_completion_step
    @mc.phase_step.completion_step.add_text_block @count, text:"Completion Step #{@count}"
    @mc.phase_step.completion_step.enable_verification
    assert @mc.phase_step.completion_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_multiple_choice
    @count += 1
    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.add_text_block @count, text:"Multiple Choice Step #{@count}"
    @mc.phase_step.multiple_choice_step.enable_verification
    assert @mc.phase_step.multiple_choice_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_attachment
    @count += 1
    @mc.phase_step.add_attachment_step
    @mc.phase_step.attachment_step.add_text_block @count, text:"Attachment Step #{@count}"
    @mc.phase_step.attachment_step.enable_verification
    assert @mc.phase_step.attachment_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_pass_fail
    @count += 1
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.add_text_block @count, text:"Pass Fail Step #{@count}"
    @mc.phase_step.pass_fail_step.enable_verification
    assert @mc.phase_step.pass_fail_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_date
    @count += 1
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block @count, text:"Date Step #{@count}"
    @mc.phase_step.date_step.enable_verification
    assert @mc.phase_step.date_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_date_time
    @count += 1
    @mc.phase_step.add_date_time_step
    @mc.phase_step.date_time_step.add_text_block @count, text:"Date Time Step #{@count}"
    @mc.phase_step.date_time_step.enable_verification
    assert @mc.phase_step.date_time_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_form_launch
    @count += 1
    @mc.phase_step.form_launching
    sleep 1
    @mc.phase_builder_form_launching_step.select_form env['sample_form_workflow']
    @mc.phase_builder_form_launching_step.save
    @mc.phase_step.form_launch_step.add_text_block @count, text:"Form Launch Step #{@count}"
    @mc.phase_step.form_launch_step.enable_verification
    assert @mc.phase_step.form_launch_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_hyperlink
    @count += 1
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step.hyperlink_step.custom_link_tab
    @mc.phase_step.hyperlink_step.add_title "hyperlink"
    @mc.phase_step.hyperlink_step.add_url "https://www.google.com"
    @mc.phase_step.hyperlink_step.save
    @mc.phase_step.hyperlink_step.add_text_block @count, text:"Hyperlink Step #{@count}"
    @mc.phase_step.hyperlink_step.enable_verification
    assert @mc.phase_step.hyperlink_step.is_verification_enabled?, @fail_message
  end

  def test_add_field_verification_property_to_fbs_integration
    @count += 1
    @mc.phase_step.add_fbs_integration_step
    @mc.phase_step.fbs_integration_step.type_of_fbs_element.click
    @mc.phase_step.fbs_integration_step.choose_type 1
    @mc.phase_step.fbs_integration_step.add_equipment @asset
    @mc.phase_step.fbs_integration_step.save_fbs_integration
    @mc.phase_step.fbs_integration_step.add_text_block @count, text:"FBS Integration Step #{@count}"
    @mc.phase_step.fbs_integration_step.enable_verification
    assert @mc.phase_step.fbs_integration_step.is_verification_enabled?, @fail_message
  end
end
