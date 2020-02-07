package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.ScraperConfig;

import java.io.*;
import java.util.*;


public class RubyScraper {

    public static List<String> scrapeTests(String key, String secondKey, boolean validation, boolean functional, boolean testPaths) {
        List<String> validationList = new ArrayList<>();
        if(validation) {
            validationList = RubyScraper.scrapeCodeUsingKeywordAndKeyword(ScraperConfig.pathToValidationFRS, key, secondKey, testPaths);
        }
        List<String> functionalList = new ArrayList<>();
        if(functional) {
            functionalList = RubyScraper.scrapeCodeUsingKeywordAndKeyword(ScraperConfig.pathToFunctionalTests, key, secondKey, testPaths);
        }
        List<String> allResults = new ArrayList<>();
        allResults.addAll(validationList);
        allResults.addAll(functionalList);
        return allResults;
    }


    public static List<String> scrapeCodeUsingKeywordAndKeyword(String pathToTests, String key, String secondKey, boolean returnTestPaths) {
        List<List<String>> scrapedData = scraper(new File(pathToTests));
        List<String> searchResults = RubyScraper.getListUsingKeywordSearchWithOptionalAnd(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        if(returnTestPaths) {
            return getFilePathOfMatchingTests(searchResults);
        }
        return searchResults;
    }

    public static List<String> getListUsingKeywordSearchWithOptionalAnd(List<List<String>> scrapedData, String key, String secondKey) {
        List<String> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.get(i).size(); a++) {
                if (scrapedData.get(i).get(a).contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
                else if (scrapedData.get(i).get(a).contains(key)) {
                    for (int count = 0; count < scrapedData.get(i).size(); count++) {
                        if (scrapedData.get(i).get(count).contains(secondKey)) {
                            categoryList.add(scrapedData.get(i).get(0));
                            break;
                        }
                    }
                    break;
                }
            }
        }
        return categoryList;
    }

    public static List<String> getFilePathOfMatchingTests(List<String> searchResults) {
        List<File> validationPaths = scrapeForFilePath(new File((ScraperConfig.pathToValidationFRS)));
        List<File> functionalPaths = scrapeForFilePath(new File((ScraperConfig.pathToFunctionalTests)));
        List<String> allTestPaths = new ArrayList<>();
        allTestPaths.addAll(getFilePathsFromSearchResults(validationPaths, functionalPaths, searchResults));
        return allTestPaths;
    }

    public static List<String> getFilePathsFromSearchResults(List<File> functionalFilePaths, List<File> validationFilePaths, List<String> searchResults) {
        List<String> testPaths = new ArrayList<>();
        List<File> compiledPaths = new ArrayList<>();
        compiledPaths.addAll(functionalFilePaths);
        compiledPaths.addAll(validationFilePaths);
        for(int i = 0; i < compiledPaths.size(); i++) {
            for(int n = 0; n < searchResults.size(); n++) {
                if((String.valueOf(compiledPaths.get(i)).contains((searchResults.get(n))))) {
                    testPaths.add(String.valueOf(compiledPaths.get(i)));
                }
            }
        }
        List<String> strippedPaths = FileUtils.stripTestPath(testPaths);
        return strippedPaths;
    }

    public static List<String> scrapeCodeUsingKeywordOrKeyword(String pathToTests, String key, String secondKey) {
        List<List<String>> scrapedData = scraper(new File(pathToTests));
        List<String> searchResults = RubyScraper.getListUsingKeywordSearchWithOptionalOr(scrapedData, key.toLowerCase(), secondKey.toLowerCase());
        System.out.println(searchResults.size() + " tests found using search term(s): " + key + " AND / OR " +  secondKey + "\n" + searchResults);
        return searchResults;
    }

    public static List<List<String>> scraper(File path) {
        List<List<String>> parsedData = new ArrayList<>();
        List<File> directories = FileUtils.getDirectories(path);
        for(File directory : directories) {
            List<File> filesToBeParsed = FileUtils.getFilesFromDirectory(directory);
            for (int i = 0; i < filesToBeParsed.size(); i++) {
                parsedData.add(RubyScraper.scrapeFileData(new File(String.valueOf(filesToBeParsed.get(i)))));
            }
        }
        return parsedData;
    }

    public static List<File> scrapeForFilePath(File path) {
        List<File> parsedData = new ArrayList<>();
        List<File> directories = FileUtils.getDirectories(path);
        for(File directory : directories) {
            List<File> filesToBeParsed = FileUtils.getFilesFromDirectory(directory);
            for (int i = 0; i < filesToBeParsed.size(); i++) {
                parsedData.addAll(scrapeFileDataForPath(filesToBeParsed.get(i)));
            }
        }
        return parsedData;
    }

    public static List<String> getExecutedCodeFromTests(File rubyFile) {
        List<String> values = new ArrayList<>();
        values.add(rubyFile.getName());
        try {
            String strLine;
            BufferedReader bufferedReader = FileUtils.getReaderForFile(rubyFile);
            while ((strLine = bufferedReader.readLine()) != null) {
                String tempName = strLine.trim();
                values.add(tempName.toLowerCase());
            }
            bufferedReader.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return values;
    }

    public static List<File> getRubyFilePaths(File rubyFile) {
        List<File> filePaths = new ArrayList<>();
        filePaths.add(new File(rubyFile.getAbsolutePath()));
        return filePaths;
    }

    public static List<String> getListUsingKeywordSearchWithOptionalOr(List<List<String>> scrapedData, String key, String secondKey) {
        List<String> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.get(i).size(); a++) {
                if (scrapedData.get(i).get(a).contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
                else if (scrapedData.get(i).get(a).contains(key) || scrapedData.get(i).get(a).contains(secondKey)) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
            }
        }
        return categoryList;
    }

    public static List<String> scrapeFileData(File rubyFile) {
        List<String> unparsedValues = RubyScraper.getExecutedCodeFromTests(rubyFile);
        List<String> completeValues = new ArrayList<>();
        completeValues.addAll(unparsedValues);
        return completeValues;
    }

    public static List<File> scrapeFileDataForPath(File rubyFile) {
        List<File> unparsedValues = RubyScraper.getRubyFilePaths(rubyFile);
        List<File> completeValues = new ArrayList<>();
        completeValues.addAll(unparsedValues);
        return completeValues;
    }
}
