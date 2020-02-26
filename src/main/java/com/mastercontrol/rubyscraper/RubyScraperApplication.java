package com.mastercontrol.rubyscraper;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class RubyScraperApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(RubyScraperApplication.class);
		app.run(args);
	}
}
