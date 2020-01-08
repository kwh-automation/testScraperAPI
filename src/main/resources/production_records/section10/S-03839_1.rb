require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]

    pre_test

    test_notes_are_hidden_by_default
    test_user_has_actionable_way_to_add_phase_step_note
    test_user_cannot_edit_note_after_saving
    test_notes_listed_chronologically_oldest_at_top
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection

    custom_phase = PhaseFactory.phase_customizer().with_instructions(PhaseInstructionsBuilder.new.with_notes.with_instruction_part(InstructionPartBuilder.new).build).with_phase_step(GeneralTextBuilder.new.with_notes.with_order_number(1)).with_phase_step(GeneralTextBuilder.new.with_notes.with_order_number(2)).with_order_number(1).build_single_level_master_batch_record
    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(custom_phase).build

    @mc.ebr_navigation.go_to_first("phase", @test_environment.master_batch_records[0].batch_records[0].lot_number)
    @instructions = @mc.phase.instructions
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.phase_steps[1].autocomplete
  end

  def test_notes_are_hidden_by_default
    assert !@mc.phase.phase_steps[0].notes.visible?
    assert !@instructions.notes.visible?
  end

  def test_user_has_actionable_way_to_add_phase_step_note
    note_test_value = uniq('Phase Step Note Test Value 1')
    @mc.phase.phase_steps[0].show_notes

    @mc.phase.phase_steps[0].notes.add note_text:note_test_value
    assert note_test_value == @mc.phase.phase_steps[0].notes.captured_notes[0]
  end

  def test_user_cannot_edit_note_after_saving
    assert !@mc.phase.phase_steps[0].notes.can_notes_be_entered?
  end

  def test_notes_listed_chronologically_oldest_at_top
    @mc.phase.phase_steps[1].show_notes
    first_note_test_value = "first"
    second_note_test_value = "second"

    @mc.phase.phase_steps[1].notes.add note_text:first_note_test_value
    wait_until{@mc.phase.phase_steps[1].notes.add_notes}
    @mc.phase.phase_steps[1].notes.add note_text:second_note_test_value
    assert first_note_test_value == @mc.phase.phase_steps[1].notes.captured_notes[0]
    assert second_note_test_value == @mc.phase.phase_steps[1].notes.captured_notes[1]
  end
end