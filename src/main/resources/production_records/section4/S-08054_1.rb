require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @mbr_name = uniq('test_duration_builder_')
    @product_id = uniq('id_')
    @admin = env['admin_user']
    @admin_pass = env['password']
    @lot_number = uniq('lot_')

    pre_test
    test_two_date_or_datetime_steps_are_required
    test_duration_step_can_be_added
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @mbr_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_date_step
    @mc.phase_step.add_date_time_step
  end

  def test_two_date_or_datetime_steps_are_required
    @mc.phase_step.add_duration_step warning: true
  end

  def test_duration_step_can_be_added
    @mc.phase_step.add_date_step
    @mc.phase_step.add_date_time_step
    @mc.phase_step.add_duration_step
    assert !(@mc.phase_step.duration_step.data_step_is_available? '1.1.1.2'),
           "When Date is selected, Date/Time steps should not be available."
    @mc.phase_step.duration_step.date_time
    assert !(@mc.phase_step.duration_step.data_step_is_available? '1.1.1.1'),
           "When Date/Time is selected, Date steps should not be available.."
    @mc.phase_step.duration_step.add_data_step '1.1.1.2'
    @mc.phase_step.duration_step.add_data_step '1.1.1.4'
    @mc.phase_step.duration_step.save
    @mc.phase_step.add_duration_step
    @mc.phase_step.duration_step.add_data_step '1.1.1.1'
    @mc.phase_step.duration_step.add_data_step '1.1.1.3'
    @mc.phase_step.duration_step.save
  end
end