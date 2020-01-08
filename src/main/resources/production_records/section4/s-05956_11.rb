require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @count = 1
    @title = "hyperlink"
    @url = "https://www.google.com"

    pre_test
    test_add_data_type_general_text
    test_add_data_type_numeric_data
    test_add_data_type_step_completion
    test_add_data_type_multiple_choice
    test_add_data_type_hyperlink
    test_add_data_type_attachment
    test_add_data_type_pass_fail
    test_add_date_time_data_type
    test_add_date_data_type
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("S05956_", false), uniq("1", false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    @mc.structure_builder.procedure_level.add_unit set_name: "1_Procedure"
    @mc.structure_builder.operation_level.add_unit set_name: "1_Operation"
    @mc.structure_builder.phase_level.add_unit set_name: "1_Phase"
    @mc.structure_builder.phase_level.select_unit "1"
    @mc.structure_builder.phase_level.settings "1"
    @mc.structure_builder.phase_level.open_phase_builder "1"
  end

  def test_add_data_type_general_text
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block @count, text: "Generic Text Step #{@count}"
    assert @mc.phase_step.general_text.is_short_instructions_correct?(@count, "Generic Text Step #{@count}")
  end

  def test_add_data_type_numeric_data
    @count = @count + 1
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block @count, text:"Numeric Step #{@count}"
    assert @mc.phase_step.numeric_data.is_short_instructions_correct?(@count, "Numeric Step #{@count}")
  end

  def test_add_data_type_step_completion
    @count = @count + 1
    @mc.phase_step.add_completion_step
    @mc.phase_step.completion_step.add_text_block @count, text:"Completion Step #{@count}"
    assert @mc.phase_step.completion_step.is_short_instructions_correct?(@count, "Completion Step #{@count}")
  end

  def test_add_data_type_multiple_choice
    @count = @count + 1
    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.add_text_block @count, text:"Multiple Choice Step #{@count}"
    assert @mc.phase_step.multiple_choice_step.is_short_instructions_correct?(@count, "Multiple Choice Step #{@count}")
  end

  def test_add_data_type_hyperlink
    @count = @count + 1
    @mc.phase_step.add_hyperlink_step
    @mc.phase_step.hyperlink_step.custom_link_tab
    @mc.phase_step.hyperlink_step.add_title @title
    @mc.phase_step.hyperlink_step.add_url @url
    @mc.phase_step.hyperlink_step.save
    @mc.phase_step.hyperlink_step.add_text_block @count, text:"Hyperlink Step #{@count}"
    assert @mc.phase_step.hyperlink_step.is_short_instructions_correct?(@count, "Hyperlink Step #{@count}")
  end

  def test_add_data_type_attachment
    @count = @count + 1
    @mc.phase_step.add_attachment_step
    @mc.phase_step.attachment_step.add_text_block @count, text:"Attachment Step #{@count}"
    assert @mc.phase_step.attachment_step.is_short_instructions_correct?(@count, "Attachment Step #{@count}")
  end

  def test_add_data_type_pass_fail
    @count = @count + 1
    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.add_text_block @count, text:"Pass/Fail Step #{@count}"
    assert @mc.phase_step.pass_fail_step.is_short_instructions_correct?(@count, "Pass/Fail Step #{@count}")
  end

  def test_add_date_time_data_type
    @count = @count + 1
    @mc.phase_step.add_date_time_step
    @mc.phase_step.date_time_step.add_text_block @count, text:"Date/Time Step #{@count}", type: "date-time"
    assert @mc.phase_step.date_time_step.is_short_instructions_correct?(@count, "Date/Time Step #{@count}", type: "date-time")
  end

  def test_add_date_data_type
    @count = @count + 1
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block @count, text:"Date Step #{@count}", type: "date"
    assert @mc.phase_step.date_step.is_short_instructions_correct?(@count, "Date Step #{@count}", type: "date")
  end

end
