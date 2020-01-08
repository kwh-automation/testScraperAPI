require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @master_template = uniq("data_projections_", false)
    @product_id = uniq("product_id_", false)
    @lot = uniq("lot_", false)
    @asset = uniq('asset')
    @workflow = env["sample_form_workflow"]
    @fail_message = ""
    @connection = MCAPI.new
    @phase_names = ["Phase 1", "Phase 2", "Phase 3", "Phase 4"]
    @data_types = [   "General Text Step",
                      "Numeric Step",
                      "Form Launching Step",
                      "Date Step",
                      "Date Time Step",
                      "Duration Step",
                      "Calculation Step",
                      "Multiple Choice Step",
                      "Completion Step",
                      "Attachment Step",
                      "Hyperlink Step",
                      "Pass Fail Step",
                      "FBS Integration Step"  ]

    pre_test
    test_selecting_data_projections_property
    test_ability_to_select_any_phase_step_to_project
    test_selecting_any_data_type_to_project
    test_projections_are_not_editable_and_show_as_a_reference_only
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.do.launch_calibration_form @asset,
                                   status: "Pass",
                                   next_due_date: (DateTime.now + 7).strftime("%d %b %Y"),
                                   connection: @connection
    @mc.do.create_master_batch_record @master_template, @product_id, open_phase_builder: true
    create_a_phase_with_each_data_type
    @mc.phase_step.back
    @mc.structure_builder.procedure_level.add_unit set_name: "Unit Procedure 2"
    @mc.structure_builder.operation_level.add_unit set_name: "Operation 1"
    @mc.structure_builder.phase_level.add_unit set_name: @phase_names[1]
    @mc.structure_builder.operation_level.add_unit set_name: "Operation 2"
    @mc.structure_builder.phase_level.add_unit set_name: @phase_names[2]
    @mc.structure_builder.phase_level.add_unit set_name: "Phase with data projections"
    @mc.structure_builder.phase_level.add_unit set_name: @phase_names[3]
    @mc.structure_builder.phase_level.configure_phase 2
  end

  def test_selecting_data_projections_property
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.enable_data_projections
    assert @mc.modal_data_projections.select_phase_label_element.visible?, "The data projections modal did not open."
  end

  def test_ability_to_select_any_phase_step_to_project
    @mc.modal_data_projections.available_phases_element.send_keys "Phase"
    @phase_names.each do |phase|
      @mc.wait_for_video time: 0.5
      @mc.modal_data_projections.available_phases_element.send_keys [:down]
      @fail_message = "The phase '#{phase}' was not found in the list of available phases."
      assert (@mc.modal_data_projections.is_phase_available_to_choose? phase), @fail_message
    end

    @mc.modal_data_projections.choose_phase "1.1.1 - Phase 1"
    @mc.wait_for_video

    (1..14).each do |num|
      @fail_message = "Phase step number '1.1.1.#{num}' was not found in the list of available phase steps."
      assert (@mc.modal_data_projections.is_step_available_to_choose? "1.1.1.#{num}"), @fail_message
    end
  end

  def test_selecting_any_data_type_to_project
    @mc.modal_data_projections.select_all_element.click
    @mc.wait_for_video time: 1
    @mc.modal_data_projections.add
    wait_until { !(@mc.modal_data_projections.is_step_available_to_choose? "1.1.1.1") }
    @mc.modal_data_projections.save
    @data_types.each do |type|
      @fail_message = "The data type '#{type}' does not appear in the list of data projections."
      assert (@mc.phase_step.general_text.data_projection_listed type), @fail_message
    end
  end

  def test_projections_are_not_editable_and_show_as_a_reference_only
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @master_template, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@master_template}", @lot

    enter_data_for_projections
    @mc.ebr_navigation.sidenav_navigate_to "2.2.2"
    5.times do
      rautomation_window.send_keys :tab
    end
    rautomation_window.send_keys :arrow_down
    rautomation_window.send_keys :arrow_down

    step = @mc.phase.phase_steps[0]
    @data_types.each do |type|
      assert (step.shown_in_data_projection type),
             "could not find '#{type}' listed in the data projections"
    end
  end

  private

  def create_a_phase_with_each_data_type
    @mc.phase_step.add_general_text
    @mc.phase_step.general_text.add_text_block 1, text: @data_types[0]

    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block 2, text: @data_types[1]

    @mc.phase_step.form_launching
    sleep 1
    @mc.phase_builder_form_launching_step.select_form @workflow
    @mc.phase_builder_form_launching_step.save
    @mc.phase_step.form_launch_step.add_text_block 3, text: @data_types[2]

    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block 4, text: @data_types[3] + " 1"
    @mc.phase_step.add_date_step
    @mc.phase_step.date_step.add_text_block 5, text: @data_types[3] + " 2"

    @mc.phase_step.add_date_time_step
    @mc.phase_step.date_time_step.add_text_block 6, text: @data_types[4]

    @mc.phase_step.add_duration_step
    @mc.phase_step.duration_step.add_data_step "1.1.1.4"
    @mc.phase_step.duration_step.add_data_step "1.1.1.5"
    @mc.phase_step.duration_step.save
    @mc.phase_step.duration_step.add_text_block 7, text: @data_types[5]

    @mc.phase_step.add_calculation_step
    @mc.phase_step.calculation_step.add_data_step "1.1.1.2"
    @mc.phase_step.calculation_step.add
    @mc.phase_step.calculation_step.one
    @mc.phase_step.calculation_step.save
    @mc.phase_step.calculation_step.add_text_block 8, text: @data_types[6]

    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 0, "option 1"
    @mc.phase_step.multiple_choice_step.add_multiple_choice_value
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 1, "option 2"
    @mc.phase_step.multiple_choice_step.add_text_block 9, text: @data_types[7]

    @mc.phase_step.add_completion_step
    @mc.phase_step.completion_step.add_text_block 10, text: @data_types[8]

    @mc.phase_step.add_attachment_step
    @mc.phase_step.attachment_step.add_text_block 11, text: @data_types[9]

    @mc.phase_step.add_hyperlink_step
    @mc.phase_step.hyperlink_step.custom_link_tab
    @mc.phase_step.hyperlink_step.add_title "hyperlink"
    @mc.phase_step.hyperlink_step.add_url "https://www.google.com"
    @mc.phase_step.hyperlink_step.save
    @mc.phase_step.hyperlink_step.add_text_block 12, text: @data_types[10]

    @mc.phase_step.add_pass_fail_step
    @mc.phase_step.pass_fail_step.add_text_block 13, text: @data_types[11]

    @mc.phase_step.add_fbs_integration_step
    @mc.phase_step.fbs_integration_step.type_of_fbs_element.click
    @mc.phase_step.fbs_integration_step.choose_type 1
    @mc.phase_step.fbs_integration_step.add_equipment @asset
    @mc.phase_step.fbs_integration_step.save_fbs_integration
    @mc.phase_step.fbs_integration_step.add_text_block 14, text: @data_types[12]
  end

  def enter_data_for_projections
    @mc.ebr_navigation.go_to_first "Phase", @lot
    data_steps = @mc.phase.phase_steps
    data_steps[0].set_text "Text in here."
    data_steps[1].set_value "10"
    data_steps[2].launch_button @workflow
    data_steps[3].complete_date (Date.today).to_s
    data_steps[4].complete_date (Date.today).to_s
    data_steps[5].complete
    data_steps[9].complete
    data_steps[8].select_option 1
    data_steps[10].attach "#{env['resource_dir']}/eBRLabsInc.png"
    sleep 1
    data_steps[11].view_link
    sleep 1
    @mc.use_window 2
    @mc.close_tab
    @mc.use_window 1
    data_steps[11].complete
    data_steps[12].select_pass
    data_steps[13].select_option 1
  end

  def rautomation_window
    RAutomation::Window.new(title: /.*Production Records.*/i)
  end

end
