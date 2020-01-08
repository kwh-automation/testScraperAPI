package com.mastercontrol.rubyscraper;

import java.io.*;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class FileUtils {

    public static List<File> getFileByDirectory(File fileDirectory){
        List<File> files = Arrays.asList(fileDirectory.listFiles());
        if(files.size() > 0 && files != null) {
            return files;
        }
        return null;
    }

    public static BufferedReader getReaderForFile(File rubyFile) {
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

    public static List<File> getResourceDirectories(File initialDirectoryPath) {
        List<File> directoryFiles = Arrays.asList(initialDirectoryPath.listFiles());
        List<File> isDirectory = new ArrayList<>();
        for(File file : directoryFiles) {
            if(file.isDirectory()) {
                isDirectory.add(file);
            }
        }
        return isDirectory;
    }
}
