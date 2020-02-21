package com.mastercontrol.rubyscraper.utils;

import java.io.*;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

public class LocalFileUtils {

    public List<File> getFilesFromDirectory(File fileDirectory){
        List<File> files = new LinkedList<File>(Arrays.asList(fileDirectory.listFiles()));
        if(files.size() > 0 && files != null) {
            for(int i = 0; i < files.size(); i++) {
                if(files.get(i).isDirectory()) {
                    files.addAll(new LinkedList<File>(Arrays.asList(files.get(i).listFiles())));
                    files.remove(i);
                    i--;
                }
            }
            for(int i = 0; i < files.size(); i++) {
                if(!String.valueOf(files.get(i)).endsWith(".rb")) {
                    files.remove(i);
                    i--;
                }
            }
            return files;
        }
        return null;
    }

    public List<File> getDirectories(File initialDirectoryPath) {
        List<File> directoryFiles = Arrays.asList(initialDirectoryPath.listFiles());
        List<File> isDirectory = new ArrayList<>();
        for(File file : directoryFiles) {
            if(file.isDirectory()) {
                isDirectory.add(file);
            }
        }
        return isDirectory;
    }

    public File setMyMasterControlRootPath(String path) {
        File mcPath = new File(path);
        return mcPath;
    }

    public List<String> stripTestPath(List<String> results) {
        List<String> stripList = new ArrayList<>();
        for (int i = 0; i < results.size(); i++) {
            String append = results.get(i).replace("\\", "/");
            StringBuilder sb = new StringBuilder(append);
            sb.delete(0, 19);
            sb.insert(0, "\"");
            sb.insert(sb.length(), "\"");
            stripList.add(String.valueOf(sb));
        }
        return stripList;
    }

}
