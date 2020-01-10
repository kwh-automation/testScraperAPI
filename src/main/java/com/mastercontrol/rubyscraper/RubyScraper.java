package com.mastercontrol.rubyscraper;

import java.io.*;
import java.util.*;

class RubyScraper {

    public static List<List<String>> scraper(File path) {
        List<List<String>> parsedData = new ArrayList<>();
        List<File> directories = FileUtils.getResourceDirectories(path);
        for(File directory : directories) {
            List<File> filesToBeParsed = FileUtils.getFileByDirectory(directory);
            for (File file : filesToBeParsed) {
                parsedData.add(RubyScraper.scrapeFileData(new File(String.valueOf(file))));
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
                if (strLine.contains("@mc")) {
                    String tempName = strLine.trim();
                    values.add(tempName);
                }
            }
            bufferedReader.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return values;
    }

    public static List<String> createTestListFromKeyValue(List<List<String>> scrapedData, String key, String secondKey) {
        List<String> categoryList = new ArrayList<>();
        for(int i = 0; i < scrapedData.size(); i++) {
            for(int a = 0; a < scrapedData.get(i).size(); a++) {
                if (scrapedData.get(i).get(a).contains(key) && secondKey.isEmpty()) {
                    categoryList.add(scrapedData.get(i).get(0));
                    break;
                }
                else if (scrapedData.get(i).get(a).contains(key) && scrapedData.get(i).get(a).contains(secondKey)) {
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
}
