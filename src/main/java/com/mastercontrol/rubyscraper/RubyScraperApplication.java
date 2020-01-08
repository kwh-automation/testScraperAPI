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
		List<String> apiTests = createTestListFromKeyValue(scrapedData, "api");
		System.out.println(apiTests);
	}

	public static List<List<String>> scraper(File path) {
		List<List<String>> parsedData = new ArrayList<>();
		for(int i = 0; i <= 19; i++) {
			List<File> filesToBeParsed = RubyScraper.getFileByDirectoryAndName(new File(String.valueOf(handleResourceDirectories(path))));
			for (File file : filesToBeParsed) {
				parsedData.add(scrapeFileData(new File(String.valueOf(file))));
			}
		}
		return parsedData;
	}

	public static List<String> scrapeFileData(File rubyFile) {
		List<String> unparsedValues = RubyScraper.readFileForClassNames(rubyFile);
//		List<String> testValues = RubyScraper.readFileForTestNames(rubyFile);
//		List<String> parsedValues = RubyScraper.parseData(unparsedValues);
		List<String> completeValues = new ArrayList<>();
		completeValues.add(rubyFile.getName());
		completeValues.addAll(unparsedValues);
//		completeValues.addAll(parsedValues);
//		System.out.println(completeValues);
		return completeValues;
	}

	public static File handleResourceDirectories(File initialDirectoryPath) {
		List<File> directoryFiles = Arrays.asList(initialDirectoryPath.listFiles());
		for(File file : directoryFiles) {
			if(file.isDirectory()) {
				return file;
			}
		}
		return null;
	}

	public static List<String> createTestListFromKeyValue(List<List<String>> scrapedData, String key) {
		List<String> categoryList = new ArrayList<>();
		for(int i = 0; i < scrapedData.size(); i++) {
			for(int a = 0; a < scrapedData.get(i).size(); a++) {
				if (scrapedData.get(i).get(a).contains(key)) {
					categoryList.add(scrapedData.get(i).get(0));
					break;
				}
			}
		}
		return categoryList;
	}

}
