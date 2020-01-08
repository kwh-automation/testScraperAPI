require 'mastercontrol-test-suite'

class FTCreatingBatchRecord < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("1384_4")
    @product_id = @product_name
    @lot_number = uniq('1384_4')
    @invalid_lot_amount = 2147483648
    @max_lot_amount = 2147483647
    @template = "#{@product_id} #{@product_name}"

    pre_test
    test_failure_creating_production_record_due_to_no_input
    test_failure_creating_production_record_due_to_invalid_quantity
    test_failure_creating_production_record_due_to_invalid_lot_number
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder: true
    @mc.phase_step.add_general_text
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
    @mc.go_to.ebr
    @mc.ebr.batch_record_create
  end

  def test_failure_creating_production_record_due_to_no_input
    @mc.batch_record_creation.create
    error_message_properly_shows = @mc.batch_record_creation.select_a_master_batch_record?
    assert error_message_properly_shows
    error_message_properly_shows = @mc.batch_record_creation.lot_number_is_required?
    assert error_message_properly_shows
  end

  def test_failure_creating_production_record_due_to_invalid_quantity
    @mc.batch_record_creation.master_batch_record @template
    @mc.batch_record_creation.lot_number = @lot_number
    @mc.batch_record_creation.create
    error_message_properly_shows = @mc.batch_record_creation.please_enter_a_whole_number?
    assert error_message_properly_shows

    @mc.batch_record_creation.lot_amount = uniq 'e'
    @mc.batch_record_creation.lot_amount = @invalid_lot_amount
    @mc.batch_record_creation.create
    assert error_message_properly_shows
  end

  def test_failure_creating_production_record_due_to_invalid_lot_number
    @mc.batch_record_creation.master_batch_record @template
    @mc.batch_record_creation.lot_amount = @max_lot_amount
    @mc.batch_record_creation.lot_number = 'MoreThan15Characters'
    lot_number_over_limit_clips_ending = @mc.batch_record_creation.lot_number = 'MoreThan15Chara'
    assert lot_number_over_limit_clips_ending
  end

end