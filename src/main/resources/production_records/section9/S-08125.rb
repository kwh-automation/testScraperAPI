  require 'mastercontrol-test-suite'

  class EbrFRS < MCValidationTest
    include Ebr

    def test_this
      @mbr_name = uniq('test_duration_builder_')
      @product_id = uniq('id_')
      @lot_number1 = uniq('lot_')
      @user1 = uniq('duration_user_')
      @password = env['password']
      @admin = env['admin_user']
      @admin_pass = env['password']
      @dateToday = (Date.today).to_s
      @dateTomorrow = (Date.today+1).to_s
      @connection = MCAPI.new

      pre_test
      test_durations_will_complete_when_all_dependencies_are_complete
      test_user_who_completed_the_final_dependent_is_the_person_who_signs_off_the_duration
    end

    def pre_test
      MCAPIs.create_user @user1, roles: env['test_admin_role'], connection: @connection
      @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: @connection
      create_mbr
    end

    def test_durations_will_complete_when_all_dependencies_are_complete
      @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number1
      @mc.ebr_navigation.go_to_first "Phase", @lot_number1
      @mc.phase.phase_steps[0].complete_date @dateToday
      @mc.phase.phase_steps[1].complete_date @dateTomorrow
      @mc.phase.phase_steps[2].complete
      @mc.phase.phase_steps[3].complete
      sleep 1
      @mc.phase.phase_steps[4].verify_result '1.1.1.5', 1
      @step3_datetime = @mc.phase.phase_steps[2].captured_value.to_i
      @step4_datetime = @mc.phase.phase_steps[3].captured_value.to_i
      @mc.phase.phase_steps[5].verify_result '1.1.1.6', @step4_datetime - @step3_datetime
    end

    def test_user_who_completed_the_final_dependent_is_the_person_who_signs_off_the_duration
      @lot_number2 = uniq('2nd_lot_')
      @mc.do.create_batch_record "#{@product_id} #{@mbr_name}", @lot_number2
      @mc.ebr_navigation.go_to_first "Phase", @lot_number2
      @mc.phase.phase_steps[0].complete_date @dateToday
      @mc.phase.phase_steps[2].complete
      sleep 1
      @mc.log_out
      @mc.do.login @user1, @password, approve_trainee: true
      @mc.ebr_navigation.go_to_first "Phase", @lot_number2
      @mc.phase.phase_steps[1].complete_date @dateTomorrow
      @mc.phase.phase_steps[3].complete
      sleep 1
      @mc.batchrecord.verify_phase_step_sign_off '1.1.1.2', @user1
      @mc.batchrecord.verify_phase_step_sign_off '1.1.1.4', @user1
      @mc.batchrecord.verify_phase_step_sign_off '1.1.1.5', @user1
      @mc.batchrecord.verify_phase_step_sign_off '1.1.1.6', @user1
    end

    private

    def create_mbr
      @mc.do.create_master_batch_record @mbr_name, @product_id, open_phase_builder: true
      @mc.phase_step.add_date_step
      @mc.phase_step.add_date_step
      @mc.phase_step.add_date_time_step
      @mc.phase_step.add_date_time_step
      @mc.phase_step.add_duration_step
      @mc.phase_step.duration_step.date
      @mc.phase_step.duration_step.add_data_step '1.1.1.1'
      @mc.phase_step.duration_step.add_data_step '1.1.1.2'
      @mc.phase_step.duration_step.save
      @mc.phase_step.add_duration_step
      @mc.phase_step.duration_step.date_time
      @mc.phase_step.duration_step.add_data_step '1.1.1.3'
      @mc.phase_step.duration_step.add_data_step '1.1.1.4'
      @mc.phase_step.duration_step.save
      @mc.phase_step.back
      @mc.structure_builder.publish_mbr_from_structure_builder
      MCAPIs.approve_MBR @mbr_name, connection: @connection
    end

  end