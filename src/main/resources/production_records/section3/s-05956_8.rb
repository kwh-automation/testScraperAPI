require "mastercontrol-test-suite"

class EbrFRS < MCValidationTest
  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test
    test_adding_predecessors_to_procedure_level
    test_that_dependency_indicator_visible_at_structure_level
    test_adding_predeccesor_to_operation_level
    test_adding_predeccesor_to_phase_level
    test_that_only_siblings_can_be_added_as_predecessors
  end

  def pre_test
    @mc.do.login @admin, @admin_pass, approve_trainee: true
    @mc.ebr.open_new_mbr_structure uniq("hello"), uniq("1",false)
    @mc.structure_builder.edit_mbr.select_release_role
    @mc.structure_builder.edit_mbr.header_settings.save
    assert !@mc.structure_builder.procedure_level.view_dependencies_displayed?,
           "The view dependencies button for procedure level should not be visible."
    assert !@mc.structure_builder.operation_level.view_dependencies_displayed?,
           "The view dependencies button for operation level should not be visible."
    assert !@mc.structure_builder.phase_level.view_dependencies_displayed?,
           "The view dependencies button for phase level should not be visible."
  end

  def test_adding_predecessors_to_procedure_level
    for i in 1..5
      @mc.structure_builder.procedure_level.add_unit set_name: "Procedure: " + i.to_s
    end
    @mc.structure_builder.procedure_level.add_predecessor 3, "2"
    @mc.structure_builder.procedure_level.add_predecessor 3, "4"
    assert @mc.structure_builder.procedure_level.is_predecessor_assigned? 3, "4"
    @mc.structure_builder.procedure_level.save
    assert @mc.structure_builder.procedure_level.view_dependencies_displayed?,
           "The view dependencies button for procedure level should be visible."
    assert !@mc.structure_builder.operation_level.view_dependencies_displayed?,
           "The view dependencies button for operation level should not be visible."
    assert !@mc.structure_builder.phase_level.view_dependencies_displayed?,
           "The view dependencies button for phase level should not be visible."
  end

  def test_that_dependency_indicator_visible_at_structure_level
    assert @mc.structure_builder.is_dependency_indicator_visible? "unit-procedure", "3"
  end

  def test_adding_predeccesor_to_operation_level
    for i in 1..5
      @mc.structure_builder.operation_level.add_unit set_name: "Operation: " + i.to_s
    end
    @mc.structure_builder.operation_level.add_predecessor 3, "2"
    assert @mc.structure_builder.operation_level.is_predecessor_assigned? 3, "2"
    @mc.structure_builder.operation_level.save
    assert @mc.structure_builder.procedure_level.view_dependencies_displayed?,
           "The view dependencies button for procedure level should be visible."
    assert @mc.structure_builder.operation_level.view_dependencies_displayed?,
           "The view dependencies button for operation level should be visible."
    assert !@mc.structure_builder.phase_level.view_dependencies_displayed?,
           "The view dependencies button for phase level should not be visible."
  end

  def test_adding_predeccesor_to_phase_level
    for i in 1..5
      @mc.structure_builder.phase_level.add_unit set_name: "Phase: " + i.to_s
    end
    sleep 2
    @mc.structure_builder.operation_level.select_unit 2
    @mc.structure_builder.operation_level.settings 2
    @mc.structure_builder.operation_level.cancel

    for j in 1..5
      @mc.structure_builder.phase_level.add_unit set_name: "Phase: " + j.to_s
    end
    @mc.structure_builder.operation_level.select_unit 3
    @mc.structure_builder.operation_level.settings 3
    @mc.structure_builder.operation_level.cancel
    @mc.structure_builder.phase_level.add_predecessor 3, "1"
    @mc.structure_builder.phase_level.add_predecessor 3, "4"
    @mc.structure_builder.phase_level.add_predecessor 3, "5"
    assert @mc.structure_builder.phase_level.is_predecessor_assigned? 3, "1"
    @mc.structure_builder.phase_level.save
    assert @mc.structure_builder.procedure_level.view_dependencies_displayed?,
           "The view dependencies button for procedure level should be visible."
    assert @mc.structure_builder.operation_level.view_dependencies_displayed?,
           "The view dependencies button for operation level should be visible."
    assert @mc.structure_builder.phase_level.view_dependencies_displayed?,
           "The view dependencies button for phase level should be visible."

    @mc.structure_builder.back
    @mc.master_batch_record_list.filter_button
    @mc.master_batch_record_list.filter_product_id uniq("1", false)
    @mc.master_batch_record_list.master_batch_record_filter_apply
    @mc.master_batch_record_list.edit_master_batch_record uniq("1", false)
    assert @mc.structure_builder.procedure_level.is_predecessor_assigned? 3, "2"
    @mc.structure_builder.procedure_level.save
    assert @mc.structure_builder.operation_level.is_predecessor_assigned? 3, "2"
    @mc.structure_builder.operation_level.save
    assert @mc.structure_builder.phase_level.is_predecessor_assigned? 3, "1"
  end

  def test_that_only_siblings_can_be_added_as_predecessors
    assert !(@mc.structure_builder.phase_level.selectable_predecessors_element.attribute("innerText").include? "2.1.1")
    assert !(@mc.structure_builder.phase_level.selectable_predecessors_element.attribute("innerText").include? "1.1")
  end
end
