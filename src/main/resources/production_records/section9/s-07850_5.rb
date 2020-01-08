require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @product_name = uniq("numeric_limts_")
    @product_id = uniq("NL_")
    @lot_number = uniq("")
    @master_batch_record = @product_id + " " + @product_name

    pre_test
    test_user_can_view_exceeded_numeric_limits_in_review_by_exception
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.do.create_master_batch_record @product_name, @product_id, open_phase_builder:true
    @mc.phase_step.add_numeric
    @mc.phase_step.numeric_data.add_text_block "1", text:"Numeric Step 1"
    @mc.phase_step.numeric_data.enable_numeric_limits
    @mc.modalgeneralnumericlimits.set_minimum "1"
    @mc.modalgeneralnumericlimits.set_maximum "20"
    wait_until { @mc.modalgeneralnumericlimits.is_modal_loaded? }
    @mc.modalgeneralnumericlimits.enable_rbe
    @mc.modalgeneralnumericlimits.save_limit
    assert @mc.phase_step.limit_container_element.attribute("innerText").include? "Review by Exception"
    @mc.phase_step.back
    @mc.do.publish_master_batch_record @product_name, @product_id
  end

  def test_user_can_view_exceeded_numeric_limits_in_review_by_exception
    @mc.do.create_batch_record @master_batch_record, @lot_number
    @mc.ebr_navigation.go_to_first("phase", @lot_number)
    @mc.phase.phase_steps[0].set_value "30"
    @mc.phase.phase_steps[0].blur
    @mc.ebr_navigation.review_by_exception
    @mc.review_by_exception.toggle_gadget 1
    sleep 1
    @mc.review_by_exception.toggle_gadget 2
    sleep 1
    @mc.review_by_exception.toggle_gadget 3
    wait_until{@mc.review_by_exception.phase_step_is_listed? "1.1.1.1"}
    @mc.review_by_exception.scroll_to_phase_step "1.1.1.1"
    assert @mc.review_by_exception.phase_step_is_listed?("1.1.1.1")   
  end
end