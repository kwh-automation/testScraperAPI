package com.mastercontrol.rubyscraper;

import org.springframework.context.annotation.Bean;

import java.io.*;
import java.util.*;

class RubyScraper {
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

    public static List<String> scrapeFileData(File rubyFile) {
        List<String> unparsedValues = RubyScraper.getExecutedCodeFromTests(rubyFile);
        List<String> completeValues = new ArrayList<>();
        completeValues.addAll(unparsedValues);
        return completeValues;
    }
}
