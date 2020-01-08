# frozen_string_literal: true

require 'mastercontrol-test-suite'
class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @initial_status = 'DATA STEP'
    @second_step = 'APPROVAL STEP'
    @form = env['sample_form_workflow']
    @launched_form = ''

    pre_test
    test_launching_a_form_from_the_operation
    test_verifying_form_launch_on_review_by_exception_page
    test_current_status_of_form_is_displayed
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @lot_number = uniq('')
    @test_mbr = "#{env['mbr_product_id']} #{env['mbr_product_name']}"
    @mc.do.create_batch_record @test_mbr, @lot_number
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
    @mc.phase.phase_steps[0].set_text 'hello'
    @mc.phase.phase_steps[0].blur
  end

  def test_launching_a_form_from_the_operation
    @mc.ebr_navigation.sidenav_navigate_to '1.1'
    @mc.accountability.launch_operation_form '1.1'
    @mc.batch_record_form_launch.select_form '1.1', form: @form
    @mc.batch_record_form_launch.launch phase_step: '1.1'
    assert @mc.accountability.form_was_launched? '1.1'
    @launched_form = @mc.accountability.get_launched_form '1.1'
    @mc.wait_for_video
  end

  def test_verifying_form_launch_on_review_by_exception_page
    @mc.ebr_navigation.review_by_exception
    wait_until { @mc.review_by_exception.toggle_form_element.visible? }
    @mc.review_by_exception.toggle_form
    assert @mc.review_by_exception.form_status?('1.1')
  end

  def test_current_status_of_form_is_displayed
    assert @mc.review_by_exception.form_status('1.1') == @initial_status
    @mc.review_by_exception.toggle_gadget '2'
    assert @mc.review_by_exception.form_was_launched?('1.1')
    assert @mc.review_by_exception.launched_form('1.1') == @launched_form
    @mc.review_by_exception.open_launched_form '1.1'
    @mc.wait_for_video
    @mc.ztest_form01.page_one.form_number = '21'
    @mc.do.sign_off '2', status: 'Data Complete'
    @mc.use_last_window
    @mc.refresh
    @mc.review_by_exception.toggle_form
    @mc.review_by_exception.toggle_gadget '2'
    assert @mc.review_by_exception.form_status('1.1') == @second_step
  end
end
