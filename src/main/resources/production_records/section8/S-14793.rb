require "mastercontrol-test-suite"
class EbrFRS < MCFunctionalTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @MBR_name = uniq('Testing Flyouts ')
    @MBR_id = uniq('id')
    @lot_number = uniq('Lot_')
    @multiple_choice = 'Multiple Choice Step 1'
    @option_1 = 'Option 1'
    @option_2 = 'Option 2'
    @order_label = '1.1.1.1'

    pre_test
    test_table_headers_display_phase_step_title_and_choices
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @MBR_name, @MBR_id, open_phase_builder: true
    @mc.phase_step.add_multiple_choice_step
    @mc.phase_step.multiple_choice_step.add_text_block 1, text: @multiple_choice
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 0, @option_1
    @mc.phase_step.multiple_choice_step.add_multiple_choice_value
    @mc.phase_step.multiple_choice_step.edit_multiple_choice_value 1, @option_2
    @mc.phase_builder.phase_iterator
    @mc.phase_step.general_text.back
    @mc.do.publish_master_batch_record @MBR_name, @MBR_id
    @mc.do.create_batch_record "#{@MBR_id} #{@MBR_name}", @lot_number
    @mc.ebr_navigation.go_to_first('Phase', @lot_number)
  end

  def test_table_headers_display_phase_step_title_and_choices
    @mc.iterating_phase_table_view.click_flyout @order_label
    assert (@mc.iterating_phase_table_view.check_flyout_title @order_label).include? @multiple_choice
    assert (@mc.iterating_phase_table_view.check_flyout_options @order_label, 1).include? @option_1
    assert (@mc.iterating_phase_table_view.check_flyout_options @order_label, 2).include? @option_2
  end
end
