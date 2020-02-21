package com.mastercontrol.rubyscraper.config;

import com.mastercontrol.rubyscraper.utils.LocalFileUtils;
import lombok.Getter;

@Getter
public class RubyScraperConfig {

    LocalFileUtils localFileUtils = new LocalFileUtils();

    private final String masterControlRoot = "C:\\QA\\";
    private final String defaultPathToTests = "\\mastercontrol\\services\\Presentation\\tests\\gems\\mastercontrol-test-suite\\lib\\mastercontrol-test-suite\\tests\\";
    private final String testsPath = masterControlRoot + defaultPathToTests;
    private final String pathToValidationFRS = testsPath + "\\validation\\frs";
    private final String pathToFunctionalTests = testsPath + "\\functional";
}
