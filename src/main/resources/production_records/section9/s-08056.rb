require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @lot_number = uniq("depend")
    @prod_id = uniq("depends",false)
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_user_can_enter_a_date
  end

  def pre_test
    @mc.do.login @admin,@admin_pass,approve_trainee: true

    @mc.do.create_master_batch_record @prod_id, @prod_id, phase_count: 1, open_phase_builder: true, open_phase: "1"
    @mc.phase_step.add_date_step
    @mc.phase_step.back
    sleep 2
    @mc.do.publish_master_batch_record @prod_id, @prod_id
    @mc.do.create_batch_record "#{@prod_id} #{@prod_id}", @lot_number
    @mc.ebr_navigation.go_to_first "Unit procedure", @lot_number
    @mc.ebr_navigation.sidenav_navigate_to "1.1.1"
  end

  def test_user_can_enter_a_date
    @mc.phase.phase_steps[0].complete_date Date.today.to_s
    assert @mc.phase.phase_steps[0].completed?
    users_name_and_date_are_displayed_when_data_is_saved
  end

  private

  def users_name_and_date_are_displayed_when_data_is_saved
    assert @mc.phase.phase_steps[0].performer.include? @admin.downcase
    assert @mc.phase.phase_steps[0].date.include? @mc.phase.phase_steps[0].captured_value
  end

end