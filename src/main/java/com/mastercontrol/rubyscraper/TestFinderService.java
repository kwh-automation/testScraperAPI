package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import org.springframework.stereotype.Service;

import java.io.*;
import java.util.*;


@Service
public class TestFinderService {

    RubyScraper rubyScraper = new RubyScraper();
    RubyScraperConfig rubyScraperConfig = new RubyScraperConfig();

    public List<TestData> scrapeTests(String key, String secondKey, boolean validation, boolean functional, boolean testPaths) {
        List<TestData> allResults = new ArrayList<>();
        if(validation) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToValidationFRS(), key, secondKey));
        }
        if(functional) {
            allResults.addAll(getMatchingTestsUsingKeywordAndKeyword(rubyScraperConfig.getPathToFunctionalTests(), key, secondKey));
        }
        return allResults;
    }

    public List<TestData> getMatchingTestsUsingKeywordAndKeyword(String pathToTests, String key, String secondKey) {
        List<TestData> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<TestData> searchResults = getListUsingKeywordSearchWithOptionalAnd(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        return searchResults;
    }

    public List<TestData> getMatchingTestsUsingKeywordOrKeyword(String pathToTests, String key, String secondKey) {
        List<TestData> scrapedData = rubyScraper.scraper(new File(pathToTests));
        List<TestData> searchResults = getListUsingKeywordSearchWithOptionalOr(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        System.out.println(searchResults.size() + " tests found using search term(s): " + key + " AND / OR " +  secondKey + "\n" + searchResults);
        return searchResults;
    }

    public List<TestData> getListUsingKeywordSearchWithOptionalAnd(List<TestData> scrapedData, String key, String secondKey) {
        List<TestData> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.size(); a++) {
                if (scrapedData.get(i).testData.contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i));
                    break;
                }
                else if (scrapedData.get(i).testData.contains(key)) {
                    for (int count = 0; count < scrapedData.size(); count++) {
                        if (scrapedData.get(i).testData.contains(secondKey)) {
                            categoryList.add(scrapedData.get(i));
                            break;
                        }
                    }
                    break;
                }
            }
        }
        return categoryList;
    }

    public List<TestData> getListUsingKeywordSearchWithOptionalOr(List<TestData> scrapedData, String key, String secondKey) {
        List<TestData> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.size(); a++) {
                if (scrapedData.get(i).testData.contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i));
                    break;
                }
                else if (scrapedData.get(i).testData.contains(key) || scrapedData.get(i).testData.contains(secondKey)) {
                    categoryList.add(scrapedData.get(i));
                    break;
                }
            }
        }
        return categoryList;
    }
}
