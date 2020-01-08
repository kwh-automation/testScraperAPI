require 'mastercontrol-test-suite'
require 'date'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    @lot_number = uniq('lotnum')
    @prod_id = uniq('prodid')
    @connection = MCAPI.new

    pre_test
    test_user_can_capture_the_current_date_time
    test_users_name_and_date_time_are_displayed_when_data_is_saved
    test_corrections_can_be_configured_to_any_date_time
  end

  def pre_test
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: @connection
    create_mbr
    @mc.ebr_navigation.go_to_first 'Unit procedure', @lot_number
    @mc.ebr_navigation.sidenav_navigate_to '1.1.1'
  end

  def test_user_can_capture_the_current_date_time
    @mc.phase.phase_steps[0].complete
    wait_until { @mc.phase.phase_steps[0].completed? }
    assert @mc.phase.phase_steps[0].completed?
  end

  def test_users_name_and_date_time_are_displayed_when_data_is_saved
    assert @mc.phase.phase_steps[0].performer.include? @admin.downcase
    wait_until { @mc.phase.phase_steps[0].completed? }
    @mc.wait_for_video
    assert valid_date?(@mc.phase.phase_steps[0].captured_value)
  end

  def test_corrections_can_be_configured_to_any_date_time
    two_days_ago = ((Date.today - 2).to_s + ' 12:00')
    set_date_and_assert two_days_ago

    two_days_from_now = ((Date.today + 2).to_s + ' 12:00')
    set_date_and_assert two_days_from_now

    today = (Date.today.to_s + ' 12:00')
    set_date_and_assert today
  end

  private

  def create_mbr
    mbr_json = PhaseFactory.phase_customizer
                           .with_phase_step(
                             DateTimeBuilder.new
                             .with_correction_configuration(
                               CorrectionConfigurationBuilder.new.build
                             )
                           )
                           .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(@connection).with_master_batch_record_json(mbr_json).build
    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end

  def set_date_and_assert(date_string)
    @mc.phase.phase_steps[0].start_correction
    wait_until { @mc.phase.phase_steps[0].date_time_input_element.visible? }
    @mc.phase.phase_steps[0].set_corrections_date_as_string date_string
    @mc.phase.phase_steps[0].correction.submit_correction

    wait_until { @mc.phase.phase_steps[0].correction.date != '' }

    @mc.phase.phase_steps[0].correction.finish_correction

    assert @mc.phase.phase_steps[0].captured_value.include? date_string
  end

  def valid_date?( str, format="%Y-%m-%e %H:%M" )
    begin
      Date.strptime(str,format)
      true
    rescue ArgumentError
      false
    end
  end

end
