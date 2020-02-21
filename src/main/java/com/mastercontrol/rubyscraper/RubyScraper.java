package com.mastercontrol.rubyscraper;

import com.mastercontrol.rubyscraper.config.RubyScraperConfig;
import com.mastercontrol.rubyscraper.utils.LocalFileUtils;
import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class RubyScraper {

    RubyScraperConfig rubyScraperConfig = new RubyScraperConfig();
    LocalFileUtils localFileUtils = new LocalFileUtils();

    public List<String> getFilePathOfMatchingTests(List<String> searchResults) {
        List<File> validationPaths = getFilePath(new File((rubyScraperConfig.getPathToValidationFRS())));
        List<File> functionalPaths = getFilePath(new File((rubyScraperConfig.getPathToFunctionalTests())));
        List<String> allTestPaths = new ArrayList<>();
        allTestPaths.addAll(getFilePathsFromSearchResults(validationPaths, functionalPaths, searchResults));
        return allTestPaths;
    }

    public List<String> getFilePathsFromSearchResults(List<File> functionalFilePaths, List<File> validationFilePaths, List<String> searchResults) {
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
        List<String> strippedPaths = localFileUtils.stripTestPath(testPaths);
        return strippedPaths;
    }

    public List<List<String>> scraper(File path) {
        List<List<String>> parsedData = new ArrayList<>();
        List<File> directories = localFileUtils.getDirectories(path);
        for(File directory : directories) {
            List<File> filesToBeParsed = localFileUtils.getFilesFromDirectory(directory);
            for (int i = 0; i < filesToBeParsed.size(); i++) {
                parsedData.add(getExecutedCodeFromTests(new File(String.valueOf(filesToBeParsed.get(i)))));
            }
        }
        return parsedData;
    }

    public List<File> getFilePath(File path) {
        List<File> parsedData = new ArrayList<>();
        List<File> directories = localFileUtils.getDirectories(path);
        for(File directory : directories) {
            List<File> filesToBeParsed = localFileUtils.getFilesFromDirectory(directory);
            for (int i = 0; i < filesToBeParsed.size(); i++) {
                parsedData.addAll(scrapeFileDataForPath(filesToBeParsed.get(i)));
            }
        }
        return parsedData;
    }

    public List<String> getExecutedCodeFromTests(File rubyFile) {
        List<String> values = new ArrayList<>();
        values.add(rubyFile.getName());
        try {
            values.addAll(FileUtils.readLines(rubyFile, "UTF-8"));
            return values;
        } catch (IOException e) {
            e.printStackTrace();
            return values;
        }
    }

    public List<File> getRubyFilePaths(File rubyFile) {
        List<File> filePaths = new ArrayList<>();
        filePaths.add(new File(rubyFile.getAbsolutePath()));
        return filePaths;
    }

    public List<File> scrapeFileDataForPath(File rubyFile) {
        return getRubyFilePaths(rubyFile);
    }
}
