require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq("product_name")
    @product_id = uniq("product_id")
    @lot_number = uniq("", false)
    @workflow = env['sample_form_workflow']
    @today = DateTime.now.strftime("%F")
    @workflow_no_number = @workflow.gsub(/\d+/,"")

    pre_test
    test_launching_form_workflow_and_checking_user_date_and_time
    test_link_with_form_name_displays
    test_completing_phase_after_form_launch
  end

  def pre_test
    @mc.do.login @admin,@admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.form_launching
    assert @mc.phase_builder_form_launching_step.forms_element.visible?
    @mc.phase_builder_form_launching_step.select_form @workflow
    @mc.phase_builder_form_launching_step.save
    assert @mc.phase_step.form_launching_step_exists?(@workflow)
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.do.create_batch_record "#{@product_id} #{@product_name}", lot_number = @lot_number
    @mc.ebr_navigation.go_to_first "phase", @lot_number
  end

  def test_launching_form_workflow_and_checking_user_date_and_time
    @mc.batch_phase_step.launch_form_workflow @workflow
    wait_until{@mc.phase.phase_steps[0].performer.include? "#{@admin.downcase} #{@admin.downcase}"}
    assert @mc.phase.phase_steps[0].date =~ /.*#{@today} \d{1,2}:\d{2}.*/
  end

  def test_link_with_form_name_displays
    assert @mc.phase.phase_steps[0].launched_form_element.text =~ /.*#{@workflow_no_number}[0-9]+.*/
    @mc.phase.phase_steps[0].launched_form
    @mc.use_next_window
    assert @mc.ztest_form01.page_one.mastercontrol_form_number_element.attribute('value') =~ /.*#{@workflow_no_number}[0-9]+.*/
    @mc.wait_for_video
    @mc.use_last_window
  end

  def test_completing_phase_after_form_launch
    @mc.phase.completion.complete
    wait_until{@mc.phase.completion.performer == "#{@admin.downcase} #{@admin.downcase}"}
    assert @mc.phase.completion.date =~ /.*#{@today} \d{1,2}:\d{2}.*/
  end

end