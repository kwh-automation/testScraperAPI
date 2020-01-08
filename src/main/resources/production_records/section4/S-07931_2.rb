require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @product_name = uniq("product_name")
    @product_id = uniq("product_id")
    @workflow = env['sample_form_workflow']

    pre_test
    test_adding_form_launch_data_type
    test_selecting_workflow_form_data_type
  end

  def pre_test
    @mc.do.login @admin,@admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
  end

  def test_adding_form_launch_data_type
    @mc.phase_step.form_launching
    assert @mc.phase_builder_form_launching_step.forms_element.visible?
  end

  def test_selecting_workflow_form_data_type
    @mc.phase_builder_form_launching_step.select_form @workflow
    @mc.phase_builder_form_launching_step.save
    assert @mc.phase_step.form_launching_step_exists?(@workflow)
  end

end