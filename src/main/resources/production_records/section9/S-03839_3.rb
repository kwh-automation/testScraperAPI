require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @lot = uniq("notes_test_")
    
    pre_test
    test_user_has_actionable_way_to_add_instructions_note
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin,@admin_pass,approve_trainee: true, connection: connection

    custom_phase = PhaseFactory
                       .phase_customizer()
                       .with_instructions(PhaseInstructionsBuilder
                                              .new.with_notes
                                              .with_instruction_part(InstructionPartBuilder.new)
                                              .build)
                       .with_phase_step(GeneralTextBuilder
                                            .new.with_notes
                                            .with_order_number(1))
                       .with_phase_step(GeneralTextBuilder
                                            .new.with_notes
                                            .with_order_number(2))
                       .with_order_number(1)
                       .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_master_batch_record_json(custom_phase)
                            .with_lot_number(@lot)
                            .with_connection(connection)
                            .build

    @mc.ebr_navigation.go_to_first("phase", @lot+"_1")
    @phase_step = @mc.phase.phase_steps[0]
    @second_phase_step = @mc.phase.phase_steps[1]
    @instructions = @mc.phase.instructions
    @mc.phase.phase_steps[0].autocomplete
    @mc.phase.phase_steps[1].autocomplete
  end

  def test_user_has_actionable_way_to_add_instructions_note
    note_test_value = uniq('Instructions Note Test Value')
    @instructions.show_notes

    @instructions.notes.add note_text:note_test_value
    assert note_test_value == (@instructions.notes.captured_notes[0])
  end

end