require "mastercontrol-test-suite"
class EBRFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @test_mbr = "#{env["mbr_product_id"]} #{env["mbr_product_name"]}"
    @lot_number = uniq("")
    @initial_status = "DATA STEP"
    @second_step = "APPROVAL STEP"
    @form = "ztest-mcml"

    pre_test
    test_viewing_all_phase_steps_where_form_was_launched
    test_current_status_of_form_is_displayed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_batch_record @test_mbr, @lot_number

    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    @mc.batch_phase_step.launch_phase_form "1.1.1.1"
    @mc.batch_record_form_launch.select_form "1.1.1.1", form: @form
    @mc.batch_record_form_launch.launch

    @mc.batch_phase_step.launch_phase_form "1.1.1.2", step: 2
    @mc.batch_record_form_launch.select_form "1.1.1.2", form: @form
    @mc.batch_record_form_launch.launch phase_step: "1.1.1.2"

    @mc.batch_phase_step.launch_phase_form "1.1.1.3", step: 3
    @mc.batch_record_form_launch.select_form "1.1.1.3", form: @form
    @mc.batch_record_form_launch.launch phase_step: "1.1.1.3"
  end

  def test_viewing_all_phase_steps_where_form_was_launched
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.toggle_form
    assert @mc.review_by_exception.form_status?("1.1.1.1")
    assert @mc.review_by_exception.form_status?("1.1.1.2")
    assert @mc.review_by_exception.form_status?("1.1.1.3")
  end

  def test_current_status_of_form_is_displayed
    assert @mc.review_by_exception.form_status("1.1.1.1") == @initial_status
    assert @mc.review_by_exception.form_status("1.1.1.2") == @initial_status
    assert @mc.review_by_exception.form_status("1.1.1.3") == @initial_status
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    @mc.batch_phase_step.launched_form "1.1.1.1"
    @mc.ztest_mcml.sign_off 2
    @mc.use_last_window
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.toggle_form
    assert @mc.review_by_exception.form_status("1.1.1.1") == @second_step
    assert @mc.review_by_exception.form_status("1.1.1.2") == @initial_status
    assert @mc.review_by_exception.form_status("1.1.1.3") == @initial_status
  end

end