package com.mastercontrol.rubyscraper;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.util.Collections;

@SpringBootApplication
public class RubyScraperApplication {

	public static void main(String[] args) {
		SpringApplication app = new SpringApplication(RubyScraperApplication.class);
		app.run(args);
	}
}
