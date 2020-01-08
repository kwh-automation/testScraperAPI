package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.*;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@SpringBootApplication
public class RubyScraperApplication {

	public static void main(String[] args) {
		List<List<String>> scrapedData = scraper(new File(String.valueOf(ScraperConfig.productionRecords)));
		List<String> apiTests = RubyScraper.createTestListFromKeyValue(scrapedData, "api");
		System.out.println(apiTests);
	}

	public static List<List<String>> scraper(File path) {
		List<List<String>> parsedData = new ArrayList<>();
		for(int i = 0; i <= 19; i++) {
			List<File> filesToBeParsed = FileUtils.getFileByDirectoryAndName(
					new File(String.valueOf(FileUtils.handleResourceDirectories(path))));
			for (File file : filesToBeParsed) {
				parsedData.add(RubyScraper.scrapeFileData(new File(String.valueOf(file))));
			}
		}
		return parsedData;
	}

}
