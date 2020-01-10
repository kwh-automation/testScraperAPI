package com.mastercontrol.rubyscraper;
import com.mastercontrol.rubyscraper.config.*;
import java.io.File;
import java.util.List;

import static com.mastercontrol.rubyscraper.RubyScraper.scraper;

public class RubyScraperApplication {

	public static void main(String[] args) {
		scrapeAndOutputData(ScraperConfig.pathToFunctionalTests, "form", "phase");
		scrapeAndOutputData(ScraperConfig.productionRecordsValidation, "api", "configuration");
	}

	public static void scrapeAndOutputData(String pathToTests, String key, String secondKey) {
		List<List<String>> scrapedData = scraper(new File(pathToTests));
		List<String> searchResults = RubyScraper.createTestListFromKeyValue(scrapedData, key, secondKey);
		System.out.println("Tests found using search term(s): " + key + ", " +  secondKey + "\n" + searchResults);
	}

}
