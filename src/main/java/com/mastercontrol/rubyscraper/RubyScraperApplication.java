package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.*;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.File;
import java.util.List;

import static com.mastercontrol.rubyscraper.RubyScraper.scraper;

@SpringBootApplication
public class RubyScraperApplication {

	public static void main(String[] args) {
		List<List<String>> scrapedData = scraper(new File(String.valueOf(ScraperConfig.productionRecords)));
		List<String> apiTests = RubyScraper.createTestListFromKeyValue(scrapedData, "variant");
		System.out.println(apiTests);
	}

}
