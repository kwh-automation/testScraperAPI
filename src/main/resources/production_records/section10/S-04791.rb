require "mastercontrol-test-suite"
require 'fileutils'

class EbrFRS < MCValidationTest
  include Ebr

  def test_this
    @admin = env["admin_user"]
    @admin_pass = env["password"]
    @role_name = uniq("notificationRole")
    @phase_order_label = "1.1.1"
    @phase_title = uniq("S-04791Phase")
    @phase_step_order_label = "1.1.1.1"
    @phase_step_title = uniq("S-04791PhaseStep")

    pre_test

    test_email_subject_contains_production_number_and_step_number
    test_email_contains_link_to_phase_step
  end

  def pre_test
    connection = MCAPI.new
    @mc.do.login @admin, @admin_pass, approve_trainee: true, connection: connection

    @email_address = "#{@admin}@mastercontrol.com"
    @mc.do.give_user_an_email_address @admin, @email_address

    @mc.do.create_role @role_name, @admin

    role_id = get_role_id(@role_name)

    custom_phase = PhaseFactory.phase_customizer()
      .with_order_label(@phase_order_label)
      .with_title(@phase_title)
      .with_phase_step(GeneralTextBuilder.new
        .with_order_label(@phase_step_order_label)
        .with_title(@phase_step_title)
        .with_notification_role_id(role_id)
        .with_order_number(1))
      .with_order_number(1)
      .build_single_level_master_batch_record

    @test_environment = EbrTestEnvironmentBuilder.new.with_connection(connection).with_master_batch_record_json(custom_phase).build

    batch_record = @test_environment.master_batch_records[0].batch_records[0]
    @lot_number = batch_record.lot_number
    @product_name = batch_record.product_name
    @create_date = batch_record.create_date.strftime("%Y-%m-%d")

    @subject = 'Field Completion Notification on ' + 'Product Name: ' + @product_name + ', Lot #: ' + @lot_number + ', Step: ' + @phase_step_order_label + ' - ' + @phase_step_title + ', Issued: ' + @create_date
    @mc.ebr_navigation.go_to_first("Phase", @lot_number, custom_name:@phase_title)
  end

  def test_email_subject_contains_production_number_and_step_number
    @mc.phase.phase_steps[0].autocomplete
    @phase_url = @mc.url
    @mc.go_to.portal
    @mc.do.wait_for_mail @email_address, subject: @subject
    assert @mc.do.check_email? @email_address, subject: @subject, delete: false
    lot_number_found_in_subject = @subject.include? @lot_number
    order_label_found_in_subject = @subject.include? @phase_step_order_label
    title_found_in_subject = @subject.include? @phase_step_title
    assert lot_number_found_in_subject
    assert order_label_found_in_subject
    assert title_found_in_subject
  end

  def test_email_contains_link_to_phase_step
    @mail_id = @mc.mailviewer.get_id(@email_address, subject: @subject)
    email_body = @mc.mailviewer.message_body @mail_id
    link_url = email_body[/href=".*?index.cfm\?(.*?)"/,1].downcase.split("%2fiteration%2f")[0].split('=')[1].gsub("%23", "#").gsub("%2f", "/")
    assert @phase_url.include?(link_url), "The link: #{@phase_url} did not match #{link_url}."
  end

  private
  def get_role_id role_name
    sql_query = "SELECT [role_id] FROM [portal_role] WHERE [role_name] = N'#{role_name}'"
    result = @mc.do.run_query(sql_query, print_query: true)
    result[0][0]
  end

end