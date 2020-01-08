# frozen_string_literal: true

require 'mastercontrol-test-suite'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env['admin_user']
    @admin_pass = env['password']
    @connection = MCAPI.new

    pre_test
    test_enforcing_general_text_field_limit_when_entered_data_is_too_short
    test_enforcing_general_text_field_limit_when_entered_data_is_too_long
    test_general_text_accepting_unicode_characters
    test_general_text_accepting_emoji_characters
    test_general_text_accepting_alpha_numeric_characters
    test_that_text_saves_when_focus_moves
    test_that_name_and_timestamp_are_captured
  end

  def pre_test
    create_batch_record
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
    @mc.ebr_navigation.go_to_first('phase', @lot_number)
  end

  def test_enforcing_general_text_field_limit_when_entered_data_is_too_short
    too_short = '123'

    @mc.phase.phase_steps[0].set_text too_short
    @mc.phase.phase_steps[0].blur wait_for_completion: false

    assert @mc.phase.phase_steps[0].out_of_specification?
  end

  def test_enforcing_general_text_field_limit_when_entered_data_is_too_long
    too_long = '1234567891011121314151617181920'

    @mc.phase.phase_steps[0].set_text too_long
    @mc.phase.phase_steps[0].blur wait_for_completion: false

    assert @mc.phase.phase_steps[0].out_of_specification?
  end

  def test_general_text_accepting_unicode_characters
    double_byte_test_value = 'ポ ㍅ É漢う'
    general_text = @mc.phase.phase_steps[0]

    general_text.set_text double_byte_test_value
    general_text.blur

    assert general_text.captured_value == double_byte_test_value
  end

  def test_general_text_accepting_emoji_characters
    emoji_test_value = "\u{2049}\u{20E3}\u{2122}\u{2139}\u{2194}-\u{2199}\u{21A9}-\u{21AA}\u{231A}-\u{231B}\u{23E9}-"\
                       "\u{23EC}\u{23F0}\u{23F3}\u{24C2}\u{25AA}-\u{25AB}\u{25B6}\u{25C0}\u{25FB}-\u{25FE}\u{2600}-"\
                       "\u{2601}\u{260E}\u{2611}\u{2614}-\u{2615}\u{261D}\u{263A}\u{2648}-\u{2653}\u{2660}\u{2663}"\
                       "\u{2665}-\u{2666}\u{2668}\u{267B}\u{267F}\u{2693}\u{26A0}-\u{26A1}\u{26AA}-\u{26AB}\u{26BD}-"\
                       "\u{26BE}\u{26C4}-\u{26C5}\u{26CE}\u{26D4}\u{26EA}\u{26F2}-\u{26F3}\u{26F5}\u{26FA}\u{26FD}"\
                       "\u{2702}\u{2705}\u{2708}-\u{270C}\u{270F}\u{2712}\u{2714}\u{2716}\u{2728}\u{2733}-\u{2734}"\
                       "\u{2744}\u{2747}\u{274C}\u{274E}\u{2753}-\u{2755}\u{2757}\u{2764}\u{2795}-\u{2797}\u{27A1}"\
                       "\u{27B0}\u{2934}-\u{2935}\u{2B05}-\u{2B07}\u{2B1B}-\u{2B1C}\u{2B50}\u{2B55}\u{3030}\u{303D}"\
                       "\u{3297}\u{3299}"
    general_text = @mc.phase.phase_steps[1]

    general_text.set_text emoji_test_value
    general_text.blur

    assert general_text.captured_value == emoji_test_value
  end

  def test_general_text_accepting_alpha_numeric_characters
    @alpha_numeric_test_value = 'AaBbCcDdEeFfGgHhIi1234567890!@$%^&*)('
    @mc.phase.phase_steps[2].set_text @alpha_numeric_test_value
  end

  def test_that_text_saves_when_focus_moves
    @mc.phase.phase_steps[2].blur

    assert @mc.phase.phase_steps[2].captured_value == @alpha_numeric_test_value
  end

  def test_that_name_and_timestamp_are_captured
    assert @mc.phase.phase_steps[0].performer.include?(@admin.downcase)
    assert @mc.do.check_time(@mc.phase.phase_steps[0].date)
  end

  private

  def create_batch_record
    custom_phase =
      PhaseFactory.phase_customizer
                  .with_phase_step(GeneralTextBuilder.new
                               .with_minimum_length(5)
                               .with_maximum_length(20)
                               .with_order_number(1))
                  .with_phase_step(GeneralTextBuilder.new.with_minimum_length(5).with_maximum_length(250))
                  .with_phase_step(GeneralTextBuilder.new.with_minimum_length(5).with_maximum_length(250))
                  .build_single_level_master_batch_record

    @test_environment =
      EbrTestEnvironmentBuilder.new
                               .with_master_batch_record_json(custom_phase)
                               .with_connection(@connection)
                               .build

    @lot_number = @test_environment.master_batch_records[0].batch_records[0].lot_number
  end
end
