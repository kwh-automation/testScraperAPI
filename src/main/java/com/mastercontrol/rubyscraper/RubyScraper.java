package com.mastercontrol.rubyscraper;

import org.springframework.context.annotation.Bean;

import java.io.*;
import java.util.*;
import java.util.stream.Collectors;

class RubyScraper {

    @Bean
    public static List<String> readFileForClassNames(File rubyFile) {
        List<String> values = new ArrayList<>();
        try {
            String strLine;
            BufferedReader bufferedReader = getReaderFromFile(rubyFile);
            while ((strLine = bufferedReader.readLine()) != null) {
                if (strLine.contains("@mc")) {
                    String tempName = strLine.trim();
                    values.add(tempName);
                }
            }
            //Close the input stream
            bufferedReader.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return values;
    }

    public static List<String> readFileForTestNames(File rubyFile) {
        List<String> values = new ArrayList<>();
        try {
            String strLine;
            BufferedReader bufferedReader = getReaderFromFile(rubyFile);
            while ((strLine = bufferedReader.readLine()) != null) {
                if (strLine.contains("test_") && !strLine.contains("test_this") && !strLine.contains("def") &&
                        !strLine.contains("@") && !strLine.contains("=") && !strLine.contains("_value")) {
                    String tempName = strLine.trim();
                    values.add(tempName);
                }
            }
            //Close the input stream
            bufferedReader.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return values;
    }

    public static List<String> parseData(List<String> valuesToParse) {
        List<String> listToSplit = new ArrayList<>();
        for(int i = 0; i < valuesToParse.size(); i++) {
            listToSplit.addAll(Arrays.asList(valuesToParse.get(i).split("\\.")));
            listToSplit.addAll(Arrays.asList(valuesToParse.get(i).split(" ")));
        }
        // Remove fluff from list
        List <String> tokens = new ArrayList<>();
        tokens = splitOnCommonDelims(listToSplit, tokens);
        Collections.sort(tokens);
        List<String> uniqueItems = tokens.stream().distinct().collect(Collectors.toList());
        List<Integer> frequencyList = new ArrayList<>();
        for(String item : uniqueItems) {
            frequencyList.add(Collections.frequency(tokens, item));
        }
        return getHighestValuesFromList(frequencyList, uniqueItems);
    }

    public static List<File> getFileByDirectoryAndName(File fileDirectory){
        List<File> files = Arrays.asList(fileDirectory.listFiles());
        if(files.size() > 0 && files != null) {
            return files;
        }
        return null;
    }

    public static BufferedReader getReaderFromFile(File rubyFile) {
        List<File> fileList = new ArrayList<>();
        fileList.add(rubyFile);
        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(fileList.get(0));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        InputStreamReader is = new InputStreamReader(inputStream);
        BufferedReader bufferedReader = new BufferedReader(is);
        return bufferedReader;
    }

    public static List<String> getHighestValuesFromList(List<Integer> frequencyList, List<String> uniqueItems) {
        int currentHigh = 0;
        int secondHighest = 0;
        int indexHigh = 0;
        int indexSecondHighest = 0;
        for(int i = 0; i < frequencyList.size(); i++) {
            if(frequencyList.get(i) >= currentHigh) {
                secondHighest = currentHigh;
                currentHigh = frequencyList.get(i);
                indexSecondHighest = indexHigh;
                indexHigh = i;
            }
        }

        List<String> parsedDataForFile = new ArrayList<>();
        parsedDataForFile.add(uniqueItems.get(indexHigh));
        parsedDataForFile.add(String.valueOf(currentHigh));
        parsedDataForFile.add(uniqueItems.get(indexSecondHighest));
        parsedDataForFile.add(String.valueOf(secondHighest));
        return parsedDataForFile;
    }

    public static List<String> splitOnCommonDelims(List<String> listToSplit, List<String> tokens) {
        for(int i = 0; i < listToSplit.size(); i++) {
            String delim = "@mc";
            tokens.addAll(Arrays.asList(listToSplit.get(i).split(delim)));
            String delims = " ";
            tokens.addAll(Arrays.asList(listToSplit.get(i).split(delim)));
        }
        for(int i = 0; i < tokens.size(); i++) {
            if(tokens.get(i).length() <= 3 |tokens.get(i).contains("@") || tokens.get(i).contains("go_to") ||
                    tokens.get(i).contains("do") || tokens.get(i).contains("=") || tokens.get(i).contains(" ") || tokens.get(i).contains("test_value") ||
                    tokens.get(i).contains("wait_until") || tokens.get(i).contains("login") || tokens.get(i).contains("connection") ||
                    tokens.get(i).contains("include") || tokens.get(i).contains("assert") || tokens.get(i).contains("MCAPI") ||
                    tokens.get(i).contains("true") || tokens.get(i).contains("false") || tokens.get(i).contains("navig") ||
                    tokens.get(i).contains("approve_trainee") || tokens.get(i).contains("The") || tokens.get(i).contains("attribute(") ||
                    tokens.get(i).contains("exists?")) {
                tokens.remove(tokens.get(i));
                --i;
            }
        }
        return tokens;
    }
}
